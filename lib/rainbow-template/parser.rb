module Rainbow
  module Template
    # The parser is responsible for taking a string template
    # and converting it into an array of tokens (S-expressions)
    class Parser
      attr_accessor :variable_tags, :block_tags

      def initialize
        @variable_tags = []
        @block_tags = []
      end

      def call(template)
        @scanner = StringScanner.new(template)
        @blocks = []
        @result = [:multi]

        until @scanner.eos?
          scan_tags || scan_text
        end

        if !@blocks.empty?
          # We have unclosed block
          while @blocks.size != 0
            open_block_tag, result = @blocks[-1]
            current_block = @result
            @result = result
            @result.last << (current_block)
            @blocks.pop
          end
        end

        return @result
      end

      # Find {title} and push them into @result
      def scan_tags
        at_start_of_line = @scanner.beginning_of_line?
        pre_match_pos = @scanner.pos

        return nil unless x = @scanner.scan(/([\s\t]*)?#{Regexp.escape(otag)}/)
        padding = @scanner[1]

        @result << [:static, padding] unless padding.empty?
        pre_match_pos += padding.length
        padding = ''

        tag_found = false
        # Find variables
        variable_tags.each do |variable|
          variable_tag = @scanner.scan(/#{variable}#{Regexp.escape(ctag)}/)
          if variable_tag
            @result << [:variable, variable_tag[0..-2]]
            tag_found = true
            break
          end
        end

        # Find blocks
        block_tags.each do |block|
          block_tag = @scanner.scan(/#{block}#{Regexp.escape(ctag)}/)
          if block_tag
            @result << [:block, block_tag[0..-2]]
            @blocks << [block_tag[0..-2], @result]
            @result = [:multi]
            tag_found = true
            break
          end

          close_block_tag = @scanner.scan(/\/#{block}#{Regexp.escape(ctag)}/)
          if close_block_tag
            if @blocks.empty?
              @result << [:close_block, close_block_tag[1..-2]]
              tag_found = true
            else
              open_block_tag, result = @blocks[-1]
              if open_block_tag != close_block_tag[1..-2]
                @result << [:close_block, close_block_tag[1..-2]]
                tag_found = true
              else
                current_block = @result
                @result = result
                @result.last << (current_block << [:close_block, close_block_tag[1..-2]])
                @blocks.pop
                tag_found = true
                break
              end
            end
          end
        end

        unless tag_found
          # Unknown content between {}
          x = @scanner.scan(/([\w]*?)#{Regexp.escape(ctag)}/)
          unknown = @scanner[1]
          @result << [:static, "#{otag}#{unknown}#{ctag}"]
        end
      end

      # Try to find static text, e.g. raw HTML with no {{mustaches}}.
      def scan_text
        text = scan_until_exclusive(/(^[ \t]*)?#{Regexp.escape(otag)}/)

        if text.nil?
          # Couldn't find any otag, which means the rest is just static text.
          text = @scanner.rest
          # Mark as done.
          @scanner.terminate
        end

        text.force_encoding(@encoding) if @encoding

        @result << [:static, text] unless text.empty?
      end

      # Scans the string until the pattern is matched. Returns the substring
      # *excluding* the end of the match, advancing the scan pointer to that
      # location. If there is no match, nil is returned.
      def scan_until_exclusive(regexp)
        pos = @scanner.pos
        if @scanner.scan_until(regexp)
          @scanner.pos -= @scanner.matched.size
          @scanner.pre_match[pos..-1]
        end
      end

      def otag
        @otag ||= "{"
      end

      def ctag
        @ctag ||= "}"
      end

    end
  end
end

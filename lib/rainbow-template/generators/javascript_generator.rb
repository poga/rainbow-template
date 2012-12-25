require 'json'

module Rainbow
  module Template
    class JavascriptGenerator
      def initialize(options = {})
        @options = options
      end

      def compile(exp, default_context)
        # Start javascript string concat template body
        @source = "__p+='"

        # We ignore the context argument, because
        # a new context will be provided at the javascript side
        #
        # Instead, we use an array to keep track the stack of variable scope
        # to perform variable lookup in javascript side
        js_compile!(exp, default_context, [])

        # close string concat
        @source += "';\n"

        # embed variable_lookup function into template function

        # wrap string concat with variable definition and returning statement
        @source = "var __p='';\n#{js_variable_lookup}\n/*template start======*/\n#{@source}\nreturn __p;"
        # wrap whole function with an anonymous function
        @source = "(function(ctx) {\n#{@source}})"

        return @source.gsub("\n", "")
      end

      alias call compile

      def otag
        @otag ||= "{"
      end

      def ctag
        @ctag ||= "}"
      end

      private

      def js_compile!(exp, context, stack)
        stack = stack.clone
        case exp.first
        when :multi
          # exp[0] = :multi
          # exp[1..-1] == array of S-expressions
          exp[1..-1].each { |e| js_compile!(e, context, stack) }
        when :static
          # exp[0] = :static
          # exp[1] = static string
          @source += "' + '#{exp[1]}' + '"
        when :variable
          # exp[0] = :variable
          # exp[1] = variable name
          @source += "' + variable_lookup(ctx, #{stack.to_json}, '#{exp[1]}') + '"
        when :block
          # exp[0] = :block
          # exp[1] = block name
          # exp[2] = multi block
          if !context[exp[1]].nil?
            if context[exp[1]] == true || context[exp[1]] == false
              # This is a true/false block
              @source += "';\n"
              @source += "if (typeof variable_lookup(ctx, #{stack.to_json}, '#{exp[1]}') == 'boolean' && variable_lookup(ctx, #{stack.to_json}, '#{exp[1]}')) { \n"
              @source += "__p+='"
              js_compile!(exp[2], context[exp[1]], stack << exp[1])
              @source += "';\n};\n__p+='"
            elsif context[exp[1]].is_a? Array
              # This is an array block
              @source += "';\n"
              @source += "if (Object.prototype.toString.call(variable_lookup(ctx, #{stack.to_json}, '#{exp[1]}')) == '[object Array]') { \n"
              @source += "  _.each(variable_lookup(ctx, #{stack.to_json}, '#{exp[1]}'), function (ctx) { \n"
              @source += " var i = 0;"
              @source += "__p+='"
              js_compile!(exp[2], context[exp[1]][0], stack)
              @source += "'; i++; \n})};\n__p+='"
            else
              # This is an object block
              # add a pointer to parent-level context,
              # so we can preform variable lookup recursively up to root level
              @source += "';\n"
              @source += "if (typeof variable_lookup(ctx, #{stack.to_json}, '#{exp[1]}') == 'object' ) { \n"
              @source += "__p+='"
              js_compile!(exp[2], context[exp[1]], stack << exp[1])
              @source += "';\n};\n__p+='"
            end
          else
             # Do nothing if the block variable does not exist
          end
        when :close_block
        end
      end

      def js_variable_lookup
        js = <<-JAVASCRIPT
          var variable_path = function (ctx, stack, name) {
            var brackets = _.map(stack, function (x) { return '["' + x + '"]'; }).join();
            return "(ctx" + brackets + ")['" + name + "']";
          };
          var variable_lookup = function (ctx, stack, name) {
              var result = eval(variable_path(ctx, stack, name));
            
              if (result === null) {
                return "";
              } else if (typeof result != "undefined") {
                return result;
              } else if (stack.length > 0) {
                return variable_lookup(ctx, stack.slice(0, -1), name);
              } else {
                return '#{otag}' + name + '#{ctag}';
              }
          };
        JAVASCRIPT

        return js
      end

    end
  end
end

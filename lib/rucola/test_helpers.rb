module Kernel
  # Stub the Rucola::RCApp.env (+RUCOLA_ENV+) for the duration of the block.
  def with_env(env)
    before = Rucola::RCApp.env
    Rucola::RCApp.stubs(:env).returns(env)
    yield
    Rucola::RCApp.stubs(:env).returns(before)
  end
  
  # Silences any warnings that might have been thrown during the execution of the block.
  # This can be handy, for instance, for when you are re-defining constants.
  def silence_warnings
    before = $VERBOSE
    $VERBOSE = nil
    yield
    $VERBOSE = before
  end
end

# Address issues with Mocha and the MacRuby named argument syntax.
module Mocha
  class ClassMethod
    def hide_original_method
      if method_exists?(method)
        begin
          #stubbee.__metaclass__.class_eval("alias_method :#{hidden_method}, :#{method}", __FILE__, __LINE__)
          stubbee.__metaclass__.send(:alias_method, hidden_method, method)
        rescue NameError
          # deal with nasties like ActiveRecord::Associations::AssociationProxy
        end
      end
    end
    
    def define_new_method
      m = method.to_s
      if m.include?(':') # MacRuby selector
        parts = m.split(':')
        
        signature = "#{parts.shift}(arg0"
        parts.each_with_index { |part, index| signature << ", #{part}: arg#{index + 1}" }
        signature << ", &block)"
        
        # def method(arg0, withExtraArg: arg1, &block)
        #   mocha.method_missing('method:withExtraArg:'.to_sym, arg0, arg1, &block)
        # end
        body = %{
          def #{signature}
            mocha.method_missing('#{method}'.to_sym, #{Array.new(parts.length + 1) { |index| "arg#{index}" }.join(', ')}, &block)
          end
        }
      else
        body = "def #{m}(*args, &block); mocha.method_missing(#{method}, *args, &block); end"
      end
      stubbee.__metaclass__.class_eval(body, __FILE__, __LINE__)
    end
    
    def remove_new_method
      stubbee.__metaclass__.send(:remove_method, method)
    end
    
    def restore_original_method
      if method_exists?(hidden_method)
        begin
          stubbee.__metaclass__.send(:alias_method, method, hidden_method)
          stubbee.__metaclass__.send(:remove_method, hidden_method)
        rescue NameError
          # deal with nasties like ActiveRecord::Associations::AssociationProxy
        end
      end
    end
  end
end
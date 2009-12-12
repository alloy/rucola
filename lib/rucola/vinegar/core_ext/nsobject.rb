module Rucola
  module Vinegar
    module CoreExt
      module NSObject
        def to_vinegar
          @_vinegar_object ||=
            Rucola::Vinegar::PROXY_MAPPINGS[self.class].new(:object => self)
        end
      end
    end
  end
end

NSObject.send(:include, Rucola::Vinegar::CoreExt::NSObject)
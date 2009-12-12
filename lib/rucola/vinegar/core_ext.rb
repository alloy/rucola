class NSObject
  def to_vinegar
    @_vinegar_object ||=
      Rucola::Vinegar::PROXY_MAPPINGS[self.class].new(:object => self)
  end
end

class NSRect
  def to_a
    origin.to_a + size.to_a
  end
end
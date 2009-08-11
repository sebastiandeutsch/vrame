class SchemaItem < HashWithIndifferentAccess # Hash
  def method_missing(method_name, *args) 
    self[method_name.to_sym]
  end
end
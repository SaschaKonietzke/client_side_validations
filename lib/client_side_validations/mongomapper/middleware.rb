module ClientSideValidations::MongoMapper
  class Middleware

    # Still need to handle embedded documents
    def self.is_unique?(klass, attribute, value, params)
      if params[:case_sensitive] == 'false'
        value = Regexp.new("^#{Regexp.escape(value.to_s)}$", Regexp::IGNORECASE)
      end

      typecasted_value = klass.keys[attribute].type.to_mongo(value)
      
      criteria = klass.where(attribute => typecasted_value)
      criteria = criteria.where(:_id => {'$ne' => BSON::ObjectId(params[:id])}) if params[:id]

      (params[:scope] || {}).each do |key, value|
        criteria = criteria.where(key => value)
      end

      !criteria.exists?
    end
  end
end

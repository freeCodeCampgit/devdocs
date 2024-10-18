require 'yajl/json_gem'

module Docs
  class Manifest
    FILENAME = 'docs.json'

    def initialize(store, docs)
      @store = store
      @docs = docs
    end

    def store
      @store.write FILENAME, to_json
    end

    def as_json
      @docs.each_with_object [] do |doc, result|
        next unless @store.exist?(doc.meta_path)
        json = JSON.parse(@store.read(doc.meta_path))
        if doc.options[:attribution].is_a?(String)
          json[:attribution] = doc.options[:attribution].strip
        end

        # parse doc aliases from JS file as Ruby hash
        entry_file = File.open("assets/javascripts/models/entry.js")
        data = entry_file.read
        aliases = eval data.split("ALIASES = ").last.split(";").first

        # set alias value
        json["alias"] = aliases[json["slug"].try(:to_sym)]

        result << json
      end
    end

    def to_json
      JSON.pretty_generate(as_json)
    end
  end
end

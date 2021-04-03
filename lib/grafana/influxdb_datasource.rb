# frozen_string_literal: true

module Grafana
  class InfluxDbDatasource < AbstractDatasource

    def initialize(ds_model)
      @model = ds_model
    end

    def model
      @model
    end

    def url(query)
      raise NotImplementedError
      "/api/datasources/proxy/#{model.id}/query"
      # db
      # q includes times somehow...
    end

    def request(query)
      {
        request: Net::HTTP::Get
      }
    end
  end
end

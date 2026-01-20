# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  # Folder where Swagger files are generated
  config.openapi_root = Rails.root.join("swagger").to_s

  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "Task Manager API",
        version: "v1",
        description: "API documentation for Task Manager"
      },
      servers: [
        {
          url: "http://localhost:3000"
        }
      ],
      paths: {},
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: :JWT
          }
        }
      },
      security: [
        { bearerAuth: [] }
      ]
    }
  }

  config.openapi_format = :yaml
end

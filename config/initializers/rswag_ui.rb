if defined?(Rswag::Ui)
  Rswag::Ui.configure do |c|
    c.swagger_endpoint '/api-docs/v1/swagger.yaml', 'Task Manager API V1'
  end
end
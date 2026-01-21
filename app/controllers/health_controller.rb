class HealthController < ApplicationController
    skip_before_action :authenticate_request
  
    def show
      db_status = begin
        ActiveRecord::Base.connection_pool.with_connection do |conn|
          conn.execute("SELECT 1")
          true
        end
      rescue => e
        false
      end
      
      render json: {
        status: "ok",
        database: db_status,
        redis: redis_alive?
      }
    end
  
    private
  
    def redis_alive?
      require "redis"
      Redis.new(url: ENV["REDIS_URL"]).ping == "PONG"
    rescue => e
      false
    end
  end
  
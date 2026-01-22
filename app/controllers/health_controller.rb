require "timeout"

class HealthController < ApplicationController
    skip_before_action :authenticate_request
  
    def show
      render json: {
        status: "ok",
        database: check_database,
        redis: redis_alive?
      }
    end
  
    private
  
    def check_database
      # Use timeout to prevent hanging on database connection failures
      Timeout.timeout(2) do
        ActiveRecord::Base.connection_pool.with_connection do |conn|
          conn.execute("SELECT 1")
          true
        end
      end
    rescue Timeout::Error, PG::ConnectionBad, ActiveRecord::ConnectionNotEstablished => e
      false
    rescue => e
      false
    end
  
    def redis_alive?
      return false unless ENV["REDIS_URL"]
      
      require "redis"
      Timeout.timeout(2) do
        Redis.new(url: ENV["REDIS_URL"]).ping == "PONG"
      end
    rescue Timeout::Error, Redis::CannotConnectError, Errno::ECONNREFUSED => e
      false
    rescue => e
      false
    end
  end
  
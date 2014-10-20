module APIv2

  module ExceptionHandlers

    def self.included(base)
      base.instance_eval do
        rescue_from Grape::Exceptions::ValidationErrors do |e|
          Rack::Response.new({
            error: {
              code: 1001,
              message: e.message
            }
          }.to_json, e.status)
        end
      end
    end

  end

  class Error < Grape::Exceptions::Base
    attr :code, :text

    # code: api error code defined by Yunbi, errors originated from
    # subclasses of Error have code start from 2000.
    # text: human readable error message
    # status: http status code
    def initialize(opts={})
      @code    = opts[:code]   || 2000
      @text    = opts[:text]   || ''

      @status  = opts[:status] || 400
      @message = {error: {code: @code, message: @text}}
    end
  end

  class AuthorizationError < Error
    def initialize
      super code: 2001, text: 'Authorization failed', status: 401
    end
  end

  class CreateOrderError < Error
    def initialize(e)
      super code: 2002, text: "Failed to create order. Reason: #{e}", status: 400
    end
  end

  class CancelOrderError < Error
    def initialize(e)
      super code: 2003, text: "Failed to cancel order. Reason: #{e}", status: 400
    end
  end

  class OrderNotFoundError < Error
    def initialize(id)
      super code: 2004, text: "Order##{id} doesn't exist.", status: 404
    end
  end

  # Errors used by inner app that needs admin privilege have code start from 3000
  # This error used for tipping api
  class InsufficientBalanceError < Error
    def initialize(uid)
      super code: 3001, text: "Account weibo##{uid} doesn't have sufficient balance.", status: 400
    end
  end

  # This error used for tipping api
  class UserNotFoundError < Error
    def initialize(uid)
      super code: 3002, text: "User weibo##{uid} doesn't exist.", status: 404
    end
  end
end

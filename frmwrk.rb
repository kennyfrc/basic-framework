# frozen_string_literal: true

require 'rack'

# Frmwrk is a simple framework that provides a simple DSL for defining
#   routes and actions.
class Frmwrk
  attr_reader :req, :res

  def initialize(&blk)
    @blk = blk
  end

  # self.app is the Rack app
  def self.app
    @app ||= Rack::Builder.new
  end

  def self.routes(&block)
    app.run new(&block)
  end

  # a prototype is a new instance of the class
  #   that is created when the class is initialized
  #   the prototype is used to call the instance methods
  #   on the class
  def self.prototype
    # app.to_app is the Rack app
    @prototype ||= app.to_app
  end

  # call the prototype's call method
  def self.call(env)
    prototype.call(env)
  end

  # duplicates the Object then calls the call! method
  #   we dup the object so that the instance variables
  #   are not shared between requests
  def call(env)
    dup.call!(env)
  end

  # call! returns the response
  def call!(env)
    @req = Rack::Request.new(env)
    @res = Rack::Response.new

    # call the block that was passed to the routes
    instance_eval(&@blk)

    # only evaluated if the block does not return a response
    if res.body.empty?
      res.status = 404
      res.write("Not Found: #{req.path}")
    end
    res.finish
  end

  # match the path to the pattern
  def match(path, pattern)
    case pattern
    when String then pattern == path || "#{pattern}/" == path
    when true then true
    else
      false
    end
  end

  # call the block if the path matches the pattern
  def on(pattern)
    # return if the path does not match the pattern
    #   without this, this will keep evaluating the succeeding blocks
    return unless match(req.path, pattern)

    res.status = 200
    yield(pattern)
  end

  # requests
  def get
    req.get?
  end
end

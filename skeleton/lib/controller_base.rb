require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    !!@already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    if already_built_response?
      raise Exception("Cant render twice")
    end
    
    @res.status = 302
    @res.location = url
    @already_built_response = true
    @session.store_session(@res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    if already_built_response?
      raise Exception("Cant render twice")
    end
    @res.write(content)
    @res['Content-Type'] = content_type
    @already_built_response = true
    @session.store_session(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = ActiveSupport::Inflector.underscore(self.class.to_s)
    dir_path = File.dirname(__FILE__)
    file_path = File.join(dir_path, "../views", controller_name, template_name.to_s + ".html.erb")
    file_obj = File.open(file_path)
    render_content(ERB.new(file_obj.read).result(binding), "text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end


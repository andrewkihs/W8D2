require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    if already_built_response?  
      raise "Double Error Render"
    end
    res.status = 302
    res.location = url
    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    res['Content-Type'] = content_type
    res.write(content)
    if already_built_response?  
      raise "Double Error Render"
    end
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.name.underscore
    folder_route = File.dirname("views/#{controller_name}/pages")
    full_route = File.join(folder_route, "#{template_name}.html.erb")
    content = File.read(full_route) 
    # debugger
    render_content(ERB.new(content).result(binding), 'text/html')

  end

  # method exposing a `Session` object
  def session
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end


# Vrame - nothing to do here, yet
module Vrame
  class NoLanguageInDatabaseError < RuntimeError; end
  
  class << self
    # The Configuration instance used to configure the NineAuthEngine
    def configuration
      @@configuration ||= Configuration.new
    end

    def configuration=(configuration)
      @@configuration = configuration
    end

    def configure
      yield Vrame.configuration if block_given?
    end
  end
  
  module Base
    def self.included(controller)
      controller.send(:include, InstanceMethods)

      controller.class_eval do
        include NineAuthEngine::Authentication

        helper VrameHelper
        helper_method :current_language

        before_filter :select_language, :except => :switch_language
      end
    end

    module InstanceMethods      
      def current_language
        @current_language
      end

      def select_language
        if session[:vrame_frontend_language_id]
          @current_language = Language.find(session[:vrame_frontend_language_id])
        else
          @current_language = Language.all.first
        end

        raise NoLanguageInDatabaseError, "You have to add a language to the database" if @current_language.nil?
        session[:vrame_frontend_language_id] = @current_language.id
        
        true
      end
      
      def switch_language
        @current_language = Language.find(params[:id])
        session[:vrame_frontend_language_id] = @current_language.id
        
        redirect_to root_path
      end

      def category_by_language
        Category.by_language(current_language)
      end

      def document_by_language
        Document.by_language(current_language)
      end
    end # /InstanceMethods
  end # /Base
  
  class Configuration
    attr_accessor :image_styles, :posterframe_styles
                  
    def initialize()  
      self.image_styles       = HashWithIndifferentAccess.new
      self.posterframe_styles = HashWithIndifferentAccess.new
    end
  end
  
end
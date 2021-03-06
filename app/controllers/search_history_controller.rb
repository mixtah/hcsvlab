# -*- encoding : utf-8 -*-
class SearchHistoryController < ApplicationController
  include Blacklight::Configurable

  copy_blacklight_config_from(CatalogController)
  before_filter :require_user_authentication_provider
  before_filter :verify_user


  def index
    @searches = searches_from_history
  end
  
  
  #TODO we may want to remove unsaved (those without user_id) items from the database when removed from history
  def clear
    if session[:history].clear
      flash[:notice] = I18n.t('blacklight.search_history.clear.success')
    else
      flash[:error] = I18n.t('blacklight.search_history.clear.failure') 
    end
    redirect_to :back
  end


  protected
  def verify_user
    flash[:notice] = I18n.t('blacklight.search_history.need_login') and raise Blacklight::Exceptions::AccessDenied unless current_user
  end
end

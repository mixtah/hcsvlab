class UserLicenceRequestsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @requests = UserLicenceRequest.where(approved: false, owner_id: current_user.id)
    @collection_data = []

    collections = Collection.where(owner_id: current_user.id, status: 'DRAFT')
    collections.each_with_index do |collection, index|
      coll_data = {}
      coll_data[:id] = collection.id
      coll_data[:name] = collection.name
      coll_data[:status] = collection.status

      email_list = []
      UserLicenceRequest.where(request_id: "#{collection.id}", request_type: 'draft_collection_read').each do |req|
        email_list << User.find(req[:user_id]).email
      end

      coll_data[:email_list] = email_list

      @collection_data << coll_data
    end
  end

  def approve_request
    @request = UserLicenceRequest.find(params[:id])
    email = @request.user_email
    coll_name = @request.request.name
    user = @request.user
    @request.approve

    Notifier.notify_user_of_approved_collection_request(user, coll_name).deliver
    redirect_to(user_licence_requests_path, :notice => "Access request for '#{email}' to #{coll_name} has been approved")
  end

  def reject_request
    @request = UserLicenceRequest.find(params[:id])
    reason = params[:reason]
    email = @request.user_email
    coll_name = @request.request.name
    user = @request.user
    @request.destroy

    Notifier.notify_user_of_rejected_collection_request(user, coll_name, reason).deliver
    redirect_to(user_licence_requests_path, :notice => "Access request for '#{email}' to #{coll_name} has been rejected")
  end

  def cancel_request
    @request = UserLicenceRequest.find(params[:id]).destroy

    redirect_to(account_licence_agreements_path, :notice => "Access request cancelled successfully")
  end

end
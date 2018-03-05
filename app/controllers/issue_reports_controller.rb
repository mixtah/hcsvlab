class IssueReportsController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource

  def new
    @issue_report ||= IssueReport.new
    @issue_report.url ||= params[:url]

    if params[:ty] == "1"
    #   request to become data owner
      @issue_report.description = %(
Dear Admin,

I want to become Alveo Data Owner to create my own collection.

Please find the brief of my collection below.

Name:
Title:
Abstract:
Description:

Thanks.

Sincerely Yours,
#{current_user.full_name}
#{current_user.email}
      )
    end

  end

  def create
    @issue_report = IssueReport.new(params[:issue_report])
    @issue_report.user_email = current_user.email
    @issue_report.timestamp = Time.now

    if @issue_report.valid?
      Notifier.notify_superusers_of_issue(@issue_report).deliver
      redirect_to(root_path, :notice => "Report was sent successfully."  )
    else
      render :new, {@issue_report => @issue_report}
    end

  end

end
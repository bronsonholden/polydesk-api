class ReportPolicy < ApplicationPolicy
  attr_reader :user, :report

  def initialize(auth, report)
    super
    @report = report
  end

  def create?
    allowed = super
    return allowed unless allowed.nil?
    has_permission?(:report_create)
  end

  def show?
    allowed = super
    return allowed unless allowed.nil?
    has_permission?(:report_show)
  end

  def index?
    allowed = super
    return allowed unless allowed.nil?
    has_permission?(:report_index)
  end

  def update?
    allowed = super
    return allowed unless allowed.nil?
    has_permission?(:report_update)
  end

  def destroy?
    allowed = super
    return allowed unless allowed.nil?
    has_permission?(:report_destroy)
  end
end

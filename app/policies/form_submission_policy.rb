class FormSubmissionPolicy < ApplicationPolicy
  def create?
    allowed = super
    return allowed unless allowed.nil?
    has_permission?(:form_submission_create)
  end

  def index?
    allowed = super
    return allowed unless allowed.nil?
    has_permission?(:form_submission_index)
  end

  def show?
    allowed = super
    return allowed unless allowed.nil?
    has_permission?(:form_submission_show)
  end

  def update?
    allowed = super
    return allowed unless allowed.nil?
    has_permission?(:form_submission_update)
  end

  def destroy?
    allowed = super
    return allowed unless allowed.nil?
    has_permission?(:form_submission_destroy)
  end

  def allowed_attributes_for_create
    [:data, :state]
  end

  def allowed_relationships_for_create
    [:form]
  end

  def allowed_attributes_for_update
    [:data, :state]
  end

  def allowed_relationships_for_update
    []
  end
end

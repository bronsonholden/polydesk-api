class FormSubmissionPolicy < ApplicationPolicy
  def create?
    true
  end

  def index?
    true
  end

  def show?
    true
  end

  def update?
    true
  end

  def destroy?
    false
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

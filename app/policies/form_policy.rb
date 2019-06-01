class FormPolicy < ApplicationPolicy
  attr_reader :user, :form

  def initialize(auth, form)
    super
    @form = form
  end

  def create?
    allowed = super
    return allowed unless allowed.nil?
    has_permission?(:form_create)
  end

  def show?
    allowed = super
    return allowed unless allowed.nil?
    has_permission?(:form_show)
  end

  def index?
    allowed = super
    return allowed unless allowed.nil?
    has_permission?(:form_index)
  end

  def update?
    allowed = super
    return allowed unless allowed.nil?
    has_permission?(:form_update)
  end

  def destroy?
    allowed = super
    return allowed unless allowed.nil?
    has_permission?(:form_destroy)
  end
end

class FolderPolicy < ApplicationPolicy
  attr_reader :user, :folder

  def initialize(auth, folder)
    super
    @folder = folder
  end

  def create?
    allowed = super
    return allowed unless allowed.nil?
    has_permission(:folder_create)
  end

  def show?
    allowed = super
    return allowed unless allowed.nil?
    has_permission(:folder_show)
  end

  def index?
    allowed = super
    return allowed unless allowed.nil?
    has_permission(:folder_index)
  end

  def update?
    allowed = super
    return allowed unless allowed.nil?
    has_permission(:folder_update)
  end

  def destroy?
    allowed = super
    return allowed unless allowed.nil?
    has_permission(:folder_destroy)
  end

  def folders?
    allowed = default_policy
    return allowed unless allowed.nil?
    has_permission(:folder_folders)
  end

  def documents?
    allowed = default_policy
    return allowed unless allowed.nil?
    has_permission(:folder_documents)
  end

  def add_document?
    allowed = default_policy
    return allowed unless allowed.nil?
    has_permission(:folder_add_document)
  end

  def add_folder?
    allowed = default_policy
    return allowed unless allowed.nil?
    has_permission(:folder_add_folder)
  end
end

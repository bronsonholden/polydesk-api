# frozen_string_literal: true

require 'uri'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
  include DeviseTokenAuth::Concerns::User
  include Discard::Model
  validates :email, presence: true, uniqueness: true
  validates_confirmation_of :password
  has_many :account_users
  has_many :accounts, through: :account_users, dependent: :destroy
  belongs_to :default_account, class_name: 'Account', optional: true

  before_create :send_confirmation_email, if: -> {
    User.devise_modules.include?(:confirmable)
  }

  def has_password?
    !encrypted_password.empty?
  end

  protected

  def password_required?
    false
  end

  private

  def send_confirmation_email
    self.send_confirmation_instructions
  end
end

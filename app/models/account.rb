# frozen_string_literal: true

require 'uri'

class Account < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
  include DeviseTokenAuth::Concerns::User
  include Discard::Model
  include Polydesk::Activation
  alias_attribute :user_name, :name
  alias_attribute :user_email, :email
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates_confirmation_of :password

  attr_readonly :account_identifier
  validates :account_identifier, uniqueness: true,
                         presence: true,
                         length: { minimum: 3, maximum: 20 },
                         format: {
                           with: /\A[a-z][a-z\-_0-9][a-z0-9]+\z/,
                           message: 'many only container lowercase letters, numbers, -, and _ and must start and end with a lowercase letter or number.'
                         }
  validates :account_name, presence: true
  has_many :account_users
  has_many :users, through: :account_users, dependent: :destroy
  has_many :inverse_account_users, class_name: 'AccountUser', foreign_key: 'user_id'
  has_many :accounts, through: :inverse_account_users, dependent: :destroy
  belongs_to :default_account, class_name: 'Account', optional: true

  before_create :send_confirmation_email, if: -> {
    #!Rails.env.test? &&
    Account.devise_modules.include?(:confirmable)
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

# frozen_string_literal: true

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User
  alias_attribute :user_name, :name
  alias_attribute :user_email, :email
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  has_many :account_users
  has_many :accounts, through: :account_users, dependent: :destroy
  belongs_to :default_account, class_name: 'Account'

  def token_validation_response
    UserSerializer.new(self).serialized_json
  end
end

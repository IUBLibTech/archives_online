# frozen_string_literal: true

class User < ApplicationRecord
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :validatable,
         :omniauthable, :omniauth_providers => [:cas]

  has_and_belongs_to_many :repositories

  enum role: { manager: 0, admin: 1 }
  after_initialize :set_default_role, if: :new_record?

  def set_default_role
    self.role ||= :manager
  end

  scope :admins, -> { where(role: :admin) }

  # Configuration added by Blacklight; Blacklight::User uses a method key on your
  # user class to get a user-displayable login/identifier for
  # the account.
  self.string_display_key ||= :email

  def self.find_for_iu_cas(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create! do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = [auth.uid,'@iu.edu'].join
      user.password = Devise.friendly_token[0,20]
    end
  end
end

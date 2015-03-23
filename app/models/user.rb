class User < ActiveRecord::Base

  has_many :myprops, :dependent => :destroy

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :current_sign_in_at, :current_sign_in_ip, :email, :encrypted_password, :last_sign_in_at, :last_sign_in_ip, :remember_created_at, :reset_password_sent_at, :reset_password_token, :sign_in_count
end

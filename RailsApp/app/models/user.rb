class User < ActiveRecord::Base

  belongs_to :company
  has_many :counts
  has_many :orders
  has_many :jobs
  has_many :user_files

  has_many :datasource_restricted_users
  has_many :datasources, through: :datasource_restricted_users

  classy_enum_attr :status, enum: 'UserStatus', default: :blocked

  validates :first_name,
    presence: true,
    format: {
      with: /\A[a-zA-Z'\-]+\z/,
      message: "only allows letters, hyphens (-) or apostrophes (')"
    },
    length: {
      minimum: 1, too_short: "is too short (minimum is %{count} characters)",
      maximum: 32, too_long: "is too long (maximum is %{count} characters)"
    }

  validates :last_name,
    format: {
      with: /\A[a-zA-Z\s'\-\.]*\z/,
      message: "only allows letters, hyphens (-), periods (.), "\
        "apostrophes (') or spaces"
    },
    allow_nil: true

  validates :email,
    presence: true,
    # uniqueness: { case_sensitive: false },
    format: /.+@.+\..+/i

  validates :userid, uniqueness: true, presence: true

  has_secure_password

  validates :password,
    length: {
      minimum: 6, too_short: "is too short (minimum is %{count} characters)"
    },
    :unless => Proc.new { |u| u.password.nil? }

  validates_presence_of :company

  before_save { email.downcase! }
  before_save { last_name.strip! if last_name.present? }
  before_save { self.remember_token =
                  SecureRandom.urlsafe_base64 if self.remember_token.nil? }

  def self.by_company(company_id)
    where("company_id = ?", company_id)
  end

  def name
    ret = first_name.dup
    ret << ' '
    ret << last_name if last_name.present?
    
    ret.squeeze(' ').strip
  end

  def masked_email
    e = email.split("@")
    e[0][0] + "*****" + "@" + e[1]
  end

  def reset_activation_token
    self.activation_token = SecureRandom.urlsafe_base64
  end

  def allowed_datasources
    self.datasources.with_deleted
  end

  def generate_auth_tokens!
    auth_token = SecureRandom.hex
    auth_code = 4.times.map{rand(10)}.join
    self.update_attributes(auth_code: auth_code, auth_token: auth_token)
  end

  def reset_auth_tokens!
    self.update_attributes(auth_code: nil, auth_token: nil)
  end

end


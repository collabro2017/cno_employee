class UserFile < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  has_and_belongs_to_many :selects
  has_many :counts_user_files
  has_many :counts, through: :counts_user_files

  validates :name,
    presence: true,
    uniqueness: { 
      scope:   :user,
      conditions: -> { where(deleted_at: nil) },
      message: "you already have a file with this name"
    }

  validates_presence_of :user

  def self.by_company(company_id)
    joins(:user).where(users:{company_id: company_id})
  end

  def self.uploaded
    where.not(uploaded_at: nil)
  end

  def mark_as_uploaded
    self.uploaded_at = DateTime.now
  end

  def uploaded?
    uploaded_at.present?
  end

  def used?
    selects.count > 0 || counts_user_files.count > 0
  end

  def used_by
    count_ids_array_1 = counts_user_files.pluck(:count_id)
    count_ids_array_2 = selects.pluck(:count_id)
    total = count_ids_array_1.concat(count_ids_array_2).uniq.count

    if total == 1
      " (in use by 1 count)"
    elsif total > 1
      " (in use by #{total} counts)"
    end
  end

  def download_url
    key = "#{self.user.email}/uploads/#{self.name}"

    bucket = AWS::S3.new.buckets[CNO::RailsApp.config.custom.s3bucket]

    bucket.objects[key].url_for(:read).to_s
  end

  def counts_user_file_for_count(count)
    self.counts_user_files.find_by(count: count)
  end
end


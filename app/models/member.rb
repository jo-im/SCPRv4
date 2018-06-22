class Member < ActiveRecord::Base
  validates :pledge_token, presence: true

  def self.create_from_parse(authorized_user)
      Member.create(
          email: authorized_user["email"],
          email_sent: authorized_user["emailSent"],
          first_name: authorized_user["name"],
          name: authorized_user["name"],
          pfs_selected: authorized_user["pfsSelected"],
          pledge_amount: authorized_user["pledgeAmount"],
          pledge_token: authorized_user["pledgeToken"],
          views_left: authorized_user["viewsLeft"]
      )
  end
end

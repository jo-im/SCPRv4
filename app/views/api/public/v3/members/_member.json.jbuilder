json.cache! [Api::Public::V3::VERSION, "v1", member] do
  # json.email          member.email
  # json.email_sent     member.email_sent
  # json.first_name     member.first_name
  # json.last_name      member.last_name
  json.member_id      member.member_id
  # json.name           member.name
  json.pfs_selected   member.pfs_selected
  # json.pledge_amount  member.pledge_amount
  json.pledge_id      member.pledge_id
  json.pledge_token   member.pledge_token
  # json.pledge_type    member.pledge_type
  # json.record_source  member.record_source
  json.views_left     member.views_left
end


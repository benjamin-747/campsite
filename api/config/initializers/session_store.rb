# frozen_string_literal: true

domain =
  case Rails.env
  when "staging-openatom"
    ".xuanwu.openatom.cn"
  when "openatom-rk8s"
    ".rk8s.xuanwu.openatom.cn"
  when "openatom-rust"
    ".rust.xuanwu.openatom.cn"
  else
    :all
  end

Rails.application.config.session_store(
  :cookie_store,
  key: "_campsite_api_session",
  domain: domain,
  same_site: :lax,
  expire_after: 1.month,
  secure: false,
)

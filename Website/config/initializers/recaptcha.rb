# -*- encoding : utf-8 -*-
ENV['RECAPTCHA_PUBLIC_KEY'] = Rails.application.secrets.recaptcha['public']
ENV['RECAPTCHA_PRIVATE_KEY'] = Rails.application.secrets.recaptcha['private']

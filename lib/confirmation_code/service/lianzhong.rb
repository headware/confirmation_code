require 'awesome_print'
require 'open-uri'
require 'httpclient'
require 'json'

module ConfirmationCode
  module Service
    module Lianzhong

      extend self
      include ConfirmationCode

      UPLOAD_URL = 'http://bbb4.hyslt.com/api.php?mod=php&act=upload'
      ACCOUNT_URL = 'http://bbb4.hyslt.com/api.php?mod=php&act=point'
      RECOGNITION_ERROR_URL = 'http://bbb4.hyslt.com/api.php?mod=php&act=error'

      def client
        @client ||= HTTPClient.new
      end

      def set_extra_options(options)

      end

      def upload(image_url, options = {})
        File.open("code.jpeg", "wb") do |f|
          f.write open(image_url).read
        end
        options = lianzhong_options.merge options
        File.open('code.jpeg') do |file|
          options['upload'] = file
          response = client.post(UPLOAD_URL, options)
          result(JSON.parse(response.body))
        end
      end

      def upload_local(image_path, options = {})
        options = lianzhong_options.merge options
        File.open(image_path) do |file|
          options['upload'] = file
          response = client.post(UPLOAD_URL, options)
          result(JSON.parse(response.body))
        end
      end

      def account(options = {})
        options = lianzhong_options.merge options
        print options
        response = client.post(ACCOUNT_URL, options)
        result(JSON.parse(response.body))
      end

      def recognition_error(ret_id, options = {})
        options['yzm_id'] = ret_id
        response = client.post(RECOGNITION_ERROR_URL, options)
        result(JSON.parse(response.body))
      end

      def lianzhong_options
        {
            yzm_minlen:  '4',
            yzm_maxlen: '6',
            yzmtype_mark: '',
            zztool_token: '',
        }
      end

      def result(body)
        {
            "success" => body['result'],
            "data" => body['data']
        }
      end
    end

  end
end
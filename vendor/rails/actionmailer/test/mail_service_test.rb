$:.unshift(File.dirname(__FILE__) + "/../lib/")

require 'test/unit'
require 'action_mailer'

class MockSMTP
  def self.deliveries
    @@deliveries
  end

  def initialize
    @@deliveries = []
  end

  def sendmail(mail, from, to)
    @@deliveries << [mail, from, to]
  end
end

class Net::SMTP
  def self.start(*args)
    yield MockSMTP.new
  end
end

class TestMailer < ActionMailer::Base

  def signed_up(recipient)
    @recipients   = recipient
    @subject      = "[Signed up] Welcome #{recipient}"
    @from         = "system@loudthinking.com"
    @sent_on      = Time.local(2004, 12, 12)
    @body["recipient"] = recipient
  end

  def cancelled_account(recipient)
    self.recipients = recipient
    self.subject    = "[Cancelled] Goodbye #{recipient}"
    self.from       = "system@loudthinking.com"
    self.sent_on    = Time.local(2004, 12, 12)
    self.body       = "Goodbye, Mr. #{recipient}"
  end

  def cc_bcc(recipient)
    recipients recipient
    subject    "testing bcc/cc"
    from       "system@loudthinking.com"
    sent_on    Time.local(2004, 12, 12)
    cc         "nobody@loudthinking.com"
    bcc        "root@loudthinking.com"
    body       "Nothing to see here."
  end

  def iso_charset(recipient)
    @recipients = recipient
    @subject    = "testing isø charsets"
    @from       = "system@loudthinking.com"
    @sent_on    = Time.local 2004, 12, 12
    @cc         = "nobody@loudthinking.com"
    @bcc        = "root@loudthinking.com"
    @body       = "Nothing to see here."
    @charset    = "iso-8859-1"
  end

  def unencoded_subject(recipient)
    @recipients = recipient
    @subject    = "testing unencoded subject"
    @from       = "system@loudthinking.com"
    @sent_on    = Time.local 2004, 12, 12
    @cc         = "nobody@loudthinking.com"
    @bcc        = "root@loudthinking.com"
    @body       = "Nothing to see here."
  end

  def extended_headers(recipient)
    @recipients = recipient
    @subject    = "testing extended headers"
    @from       = "Grytøyr <stian1@example.net>"
    @sent_on    = Time.local 2004, 12, 12
    @cc         = "Grytøyr <stian2@example.net>"
    @bcc        = "Grytøyr <stian3@example.net>"
    @body       = "Nothing to see here."
    @charset    = "iso-8859-1"
  end

  def utf8_body(recipient)
    @recipients = recipient
    @subject    = "testing utf-8 body"
    @from       = "Foo áëô îü <extended@example.net>"
    @sent_on    = Time.local 2004, 12, 12
    @cc         = "Foo áëô îü <extended@example.net>"
    @bcc        = "Foo áëô îü <extended@example.net>"
    @body       = "åœö blah"
    @charset    = "utf-8"
  end

  def multipart_with_mime_version(recipient)
    recipients   recipient
    subject      "multipart with mime_version"
    from         "test@example.com"
    sent_on      Time.local(2004, 12, 12)
    mime_version "1.1"
    content_type "multipart/alternative"

    part "text/plain" do |p|
      p.body = "blah"
    end

    part "text/html" do |p|
      p.body = "<b>blah</b>"
    end
  end

  def multipart_with_utf8_subject(recipient)
    recipients   recipient
    subject      "Foo áëô îü"
    from         "test@example.com"
    charset      "utf-8"

    part "text/plain" do |p|
      p.body = "blah"
    end

    part "text/html" do |p|
      p.body = "<b>blah</b>"
    end
  end

  def explicitly_multipart_example(recipient, ct=nil)
    recipients   recipient
    subject      "multipart example"
    from         "test@example.com"
    sent_on      Time.local(2004, 12, 12)
    body         "plain text default"
    content_type ct if ct

    part "text/html" do |p|
      p.charset = "iso-8859-1"
      p.body = "blah"
    end

    attachment :content_type => "image/jpeg", :filename => "foo.jpg",
      :body => "123456789"
  end

  def implicitly_multipart_example(recipient, cs = nil, order = nil)
    @recipients = recipient
    @subject    = "multipart example"
    @from       = "test@example.com"
    @sent_on    = Time.local 2004, 12, 12
    @body       = { "recipient" => recipient }
    @charset    = cs if cs
    @implicit_parts_order = order if order
  end

  def html_mail(recipient)
    recipients   recipient
    subject      "html mail"
    from         "test@example.com"
    body         "<em>Emphasize</em> <strong>this</strong>"
    content_type "text/html"
  end

  def html_mail_with_underscores(recipient)
    subject      "html mail with underscores"
    body         %{<a href="http://google.com" target="_blank">_Google</a>}
  end

  def custom_template(recipient)
    recipients recipient
    subject    "[Signed up] Welcome #{recipient}"
    from       "system@loudthinking.com"
    sent_on    Time.local(2004, 12, 12)
    template   "signed_up"

    body["recipient"] = recipient
  end

  def various_newlines(recipient)
    recipients   recipient
    subject      "various newlines"
    from         "test@example.com"
    body         "line #1\nline #2\rline #3\r\nline #4\r\r" +
                 "line #5\n\nline#6\r\n\r\nline #7"
  end

  def various_newlines_multipart(recipient)
    recipients   recipient
    subject      "various newlines multipart"
    from         "test@example.com"
    content_type "multipart/alternative"
    part :content_type => "text/plain", :body => "line #1\nline #2\rline #3\r\nline #4\r\r"
    part :content_type => "text/html", :body => "<p>line #1</p>\n<p>line #2</p>\r<p>line #3</p>\r\n<p>line #4</p>\r\r"
  end

  def nested_multipart(recipient)
    recipients   recipient
    subject      "nested multipart"
    from         "test@example.com"
    content_type "multipart/mixed"
    part :content_type => "multipart/alternative", :content_disposition => "inline" do |p|
      p.part :content_type => "text/plain", :body => "test text\nline #2"
      p.part :content_type => "text/html", :body => "<b>test</b> HTML<br/>\nline #2"
    end
    attachment :content_type => "application/octet-stream",:filename => "test.txt", :body => "test abcdefghijklmnopqstuvwxyz"
  end

  def unnamed_attachment(recipient)
    recipients   recipient
    subject      "nested multipart"
    from         "test@example.com"
    content_type "multipart/mixed"
    part :content_type => "text/plain", :body => "hullo"
    attachment :content_type => "application/octet-stream", :body => "test abcdefghijklmnopqstuvwxyz"
  end

  def headers_with_nonalpha_chars(recipient)
    recipients   recipient
    subject      "nonalpha chars"
    from         "One: Two <test@example.com>"
    cc           "Three: Four <test@example.com>"
    bcc          "Five: Six <test@example.com>"
    body         "testing"
  end

  class <<self
    attr_accessor :received_body
  end

  def receive(mail)
    self.class.received_body = mail.body
  end
end

TestMailer.template_root = File.dirname(__FILE__) + "/fixtures"

class ActionMailerTest < Test::Unit::TestCase
  include ActionMailer::Quoting

  def encode( text, charset="utf-8" )
    quoted_printable( text, charset )
  end

  def new_mail( charset="utf-8" )
    mail = TMail::Mail.new
    if charset
      mail.set_content_type "text", "plain", { "charset" => charset }
    end
    mail
  end

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @recipient = 'test@localhost'
  end

  def test_nested_parts
    created = nil
    assert_nothing_raised { created = TestMailer.create_nested_multipart(@recipient)}
    assert_equal 2,created.parts.size
    assert_equal 2,created.parts.first.parts.size
    
    assert_equal "multipart/mixed", created.content_type
    assert_equal "multipart/alternative", created.parts.first.content_type
    assert_equal "text/plain", created.parts.first.parts.first.content_type
    assert_equal "text/html", created.parts.first.parts[1].content_type
    assert_equal "application/octet-stream", created.parts[1].content_type
  end

  def test_signed_up
    expected = new_mail
    expected.to      = @recipient
    expected.subject = "[Signed up] Welcome #{@recipient}"
    expected.body    = "Hello there, \n\nMr. #{@recipient}"
    expected.from    = "system@loudthinking.com"
    expected.date    = Time.local(2004, 12, 12)
    expected.mime_version = nil

    created = nil
    assert_nothing_raised { created = TestMailer.create_signed_up(@recipient) }
    assert_not_nil created
    assert_equal expected.encoded, created.encoded

    assert_nothing_raised { TestMailer.deliver_signed_up(@recipient) }
    assert_not_nil ActionMailer::Base.deliveries.first
    assert_equal expected.encoded, ActionMailer::Base.deliveries.first.encoded
  end
  
  def test_custom_template
    expected = new_mail
    expected.to      = @recipient
    expected.subject = "[Signed up] Welcome #{@recipient}"
    expected.body    = "Hello there, \n\nMr. #{@recipient}"
    expected.from    = "system@loudthinking.com"
    expected.date    = Time.local(2004, 12, 12)

    created = nil
    assert_nothing_raised { created = TestMailer.create_custom_template(@recipient) }
    assert_not_nil created
    assert_equal expected.encoded, created.encoded
  end
  
  def test_cancelled_account
    expected = new_mail
    expected.to      = @recipient
    expected.subject = "[Cancelled] Goodbye #{@recipient}"
    expected.body    = "Goodbye, Mr. #{@recipient}"
    expected.from    = "system@loudthinking.com"
    expected.date    = Time.local(2004, 12, 12)

    created = nil
    assert_nothing_raised { created = TestMailer.create_cancelled_account(@recipient) }
    assert_not_nil created
    assert_equal expected.encoded, created.encoded

    assert_nothing_raised { TestMailer.deliver_cancelled_account(@recipient) }
    assert_not_nil ActionMailer::Base.deliveries.first
    assert_equal expected.encoded, ActionMailer::Base.deliveries.first.encoded
  end
  
  def test_cc_bcc
    expected = new_mail
    expected.to      = @recipient
    expected.subject = "testing bcc/cc"
    expected.body    = "Nothing to see here."
    expected.from    = "system@loudthinking.com"
    expected.cc      = "nobody@loudthinking.com"
    expected.bcc     = "root@loudthinking.com"
    expected.date    = Time.local 2004, 12, 12

    created = nil
    assert_nothing_raised do
      created = TestMailer.create_cc_bcc @recipient
    end
    assert_not_nil created
    assert_equal expected.encoded, created.encoded

    assert_nothing_raised do
      TestMailer.deliver_cc_bcc @recipient
    end

    assert_not_nil ActionMailer::Base.deliveries.first
    assert_equal expected.encoded, ActionMailer::Base.deliveries.first.encoded
  end

  def test_iso_charset
    expected = new_mail( "iso-8859-1" )
    expected.to      = @recipient
    expected.subject = encode "testing isø charsets", "iso-8859-1"
    expected.body    = "Nothing to see here."
    expected.from    = "system@loudthinking.com"
    expected.cc      = "nobody@loudthinking.com"
    expected.bcc     = "root@loudthinking.com"
    expected.date    = Time.local 2004, 12, 12

    created = nil
    assert_nothing_raised do
      created = TestMailer.create_iso_charset @recipient
    end
    assert_not_nil created
    assert_equal expected.encoded, created.encoded

    assert_nothing_raised do
      TestMailer.deliver_iso_charset @recipient
    end

    assert_not_nil ActionMailer::Base.deliveries.first
    assert_equal expected.encoded, ActionMailer::Base.deliveries.first.encoded
  end

  def test_unencoded_subject
    expected = new_mail
    expected.to      = @recipient
    expected.subject = "testing unencoded subject"
    expected.body    = "Nothing to see here."
    expected.from    = "system@loudthinking.com"
    expected.cc      = "nobody@loudthinking.com"
    expected.bcc     = "root@loudthinking.com"
    expected.date    = Time.local 2004, 12, 12

    created = nil
    assert_nothing_raised do
      created = TestMailer.create_unencoded_subject @recipient
    end
    assert_not_nil created
    assert_equal expected.encoded, created.encoded

    assert_nothing_raised do
      TestMailer.deliver_unencoded_subject @recipient
    end

    assert_not_nil ActionMailer::Base.deliveries.first
    assert_equal expected.encoded, ActionMailer::Base.deliveries.first.encoded
  end

  def test_instances_are_nil
    assert_nil ActionMailer::Base.new
    assert_nil TestMailer.new
  end

  def test_deliveries_array
    assert_not_nil ActionMailer::Base.deliveries
    assert_equal 0, ActionMailer::Base.deliveries.size
    TestMailer.deliver_signed_up(@recipient)
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not_nil ActionMailer::Base.deliveries.first
  end

  def test_perform_deliveries_flag
    ActionMailer::Base.perform_deliveries = false
    TestMailer.deliver_signed_up(@recipient)
    assert_equal 0, ActionMailer::Base.deliveries.size
    ActionMailer::Base.perform_deliveries = true
    TestMailer.deliver_signed_up(@recipient)
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  def test_unquote_quoted_printable_subject
    msg = <<EOF
From: me@example.com
Subject: =?utf-8?Q?testing_testing_=D6=A4?=
Content-Type: text/plain; charset=iso-8859-1

The body
EOF
    mail = TMail::Mail.parse(msg)
    assert_equal "testing testing \326\244", mail.subject
    assert_equal "=?utf-8?Q?testing_testing_=D6=A4?=", mail.quoted_subject
  end

  def test_unquote_7bit_subject
    msg = <<EOF
From: me@example.com
Subject: this == working?
Content-Type: text/plain; charset=iso-8859-1

The body
EOF
    mail = TMail::Mail.parse(msg)
    assert_equal "this == working?", mail.subject
    assert_equal "this == working?", mail.quoted_subject
  end

  def test_unquote_7bit_body
    msg = <<EOF
From: me@example.com
Subject: subject
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit

The=3Dbody
EOF
    mail = TMail::Mail.parse(msg)
    assert_equal "The=3Dbody", mail.body.strip
    assert_equal "The=3Dbody", mail.quoted_body.strip
  end

  def test_unquote_quoted_printable_body
    msg = <<EOF
From: me@example.com
Subject: subject
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

The=3Dbody
EOF
    mail = TMail::Mail.parse(msg)
    assert_equal "The=body", mail.body.strip
    assert_equal "The=3Dbody", mail.quoted_body.strip
  end

  def test_unquote_base64_body
    msg = <<EOF
From: me@example.com
Subject: subject
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: base64

VGhlIGJvZHk=
EOF
    mail = TMail::Mail.parse(msg)
    assert_equal "The body", mail.body.strip
    assert_equal "VGhlIGJvZHk=", mail.quoted_body.strip
  end

  def test_extended_headers
    @recipient = "Grytøyr <test@localhost>"

    expected = new_mail "iso-8859-1"
    expected.to      = quote_address_if_necessary @recipient, "iso-8859-1"
    expected.subject = "testing extended headers"
    expected.body    = "Nothing to see here."
    expected.from    = quote_address_if_necessary "Grytøyr <stian1@example.net>", "iso-8859-1"
    expected.cc      = quote_address_if_necessary "Grytøyr <stian2@example.net>", "iso-8859-1"
    expected.bcc     = quote_address_if_necessary "Grytøyr <stian3@example.net>", "iso-8859-1"
    expected.date    = Time.local 2004, 12, 12

    created = nil
    assert_nothing_raised do
      created = TestMailer.create_extended_headers @recipient
    end

    assert_not_nil created
    assert_equal expected.encoded, created.encoded

    assert_nothing_raised do
      TestMailer.deliver_extended_headers @recipient
    end

    assert_not_nil ActionMailer::Base.deliveries.first
    assert_equal expected.encoded, ActionMailer::Base.deliveries.first.encoded
  end
  
  def test_utf8_body_is_not_quoted
    @recipient = "Foo áëô îü <extended@example.net>"
    expected = new_mail "utf-8"
    expected.to      = quote_address_if_necessary @recipient, "utf-8"
    expected.subject = "testing utf-8 body"
    expected.body    = "åœö blah"
    expected.from    = quote_address_if_necessary @recipient, "utf-8"
    expected.cc      = quote_address_if_necessary @recipient, "utf-8"
    expected.bcc     = quote_address_if_necessary @recipient, "utf-8"
    expected.date    = Time.local 2004, 12, 12

    created = TestMailer.create_utf8_body @recipient
    assert_match(/åœö blah/, created.encoded)
  end

  def test_multiple_utf8_recipients
    @recipient = ["\"Foo áëô îü\" <extended@example.net>", "\"Example Recipient\" <me@example.com>"]
    expected = new_mail "utf-8"
    expected.to      = quote_address_if_necessary @recipient, "utf-8"
    expected.subject = "testing utf-8 body"
    expected.body    = "åœö blah"
    expected.from    = quote_address_if_necessary @recipient.first, "utf-8"
    expected.cc      = quote_address_if_necessary @recipient, "utf-8"
    expected.bcc     = quote_address_if_necessary @recipient, "utf-8"
    expected.date    = Time.local 2004, 12, 12

    created = TestMailer.create_utf8_body @recipient
    assert_match(/\nFrom: =\?utf-8\?Q\?Foo_.*?\?= <extended@example.net>\r/, created.encoded)
    assert_match(/\nTo: =\?utf-8\?Q\?Foo_.*?\?= <extended@example.net>, Example Recipient <me/, created.encoded)
  end

  def test_receive_decodes_base64_encoded_mail
    fixture = File.read(File.dirname(__FILE__) + "/fixtures/raw_email")
    TestMailer.receive(fixture)
    assert_match(/Jamis/, TestMailer.received_body)
  end

  def test_receive_attachments
    fixture = File.read(File.dirname(__FILE__) + "/fixtures/raw_email2")
    mail = TMail::Mail.parse(fixture)
    attachment = mail.attachments.last
    assert_equal "smime.p7s", attachment.original_filename
    assert_equal "application/pkcs7-signature", attachment.content_type
  end

  def test_decode_attachment_without_charset
    fixture = File.read(File.dirname(__FILE__) + "/fixtures/raw_email3")
    mail = TMail::Mail.parse(fixture)
    attachment = mail.attachments.last
    assert_equal 1026, attachment.read.length
  end

  def test_attachment_using_content_location
    fixture = File.read(File.dirname(__FILE__) + "/fixtures/raw_email12")
    mail = TMail::Mail.parse(fixture)
    assert_equal 1, mail.attachments.length
    assert_equal "Photo25.jpg", mail.attachments.first.original_filename
  end

  def test_decode_part_without_content_type
    fixture = File.read(File.dirname(__FILE__) + "/fixtures/raw_email4")
    mail = TMail::Mail.parse(fixture)
    assert_nothing_raised { mail.body }
  end

  def test_decode_message_without_content_type
    fixture = File.read(File.dirname(__FILE__) + "/fixtures/raw_email5")
    mail = TMail::Mail.parse(fixture)
    assert_nothing_raised { mail.body }
  end

  def test_decode_message_with_incorrect_charset
    fixture = File.read(File.dirname(__FILE__) + "/fixtures/raw_email6")
    mail = TMail::Mail.parse(fixture)
    assert_nothing_raised { mail.body }
  end

  def test_multipart_with_mime_version
    mail = TestMailer.create_multipart_with_mime_version(@recipient)
    assert_equal "1.1", mail.mime_version
  end
  
  def test_multipart_with_utf8_subject
    mail = TestMailer.create_multipart_with_utf8_subject(@recipient)
    assert_match(/\nSubject: =\?utf-8\?Q\?Foo_.*?\?=/, mail.encoded)
  end

  def test_explicitly_multipart_messages
    mail = TestMailer.create_explicitly_multipart_example(@recipient)
    assert_equal 3, mail.parts.length
    assert_nil mail.content_type
    assert_equal "text/plain", mail.parts[0].content_type

    assert_equal "text/html", mail.parts[1].content_type
    assert_equal "iso-8859-1", mail.parts[1].sub_header("content-type", "charset")
    assert_equal "inline", mail.parts[1].content_disposition

    assert_equal "image/jpeg", mail.parts[2].content_type
    assert_equal "attachment", mail.parts[2].content_disposition
    assert_equal "foo.jpg", mail.parts[2].sub_header("content-disposition", "filename")
    assert_equal "foo.jpg", mail.parts[2].sub_header("content-type", "name")
    assert_nil mail.parts[2].sub_header("content-type", "charset")
  end

  def test_explicitly_multipart_with_content_type
    mail = TestMailer.create_explicitly_multipart_example(@recipient, "multipart/alternative")
    assert_equal 3, mail.parts.length
    assert_equal "multipart/alternative", mail.content_type
  end

  def test_explicitly_multipart_with_invalid_content_type
    mail = TestMailer.create_explicitly_multipart_example(@recipient, "text/xml")
    assert_equal 3, mail.parts.length
    assert_nil mail.content_type
  end

  def test_implicitly_multipart_messages
    mail = TestMailer.create_implicitly_multipart_example(@recipient)
    assert_equal 3, mail.parts.length
    assert_equal "1.0", mail.mime_version
    assert_equal "multipart/alternative", mail.content_type
    assert_equal "text/yaml", mail.parts[0].content_type
    assert_equal "utf-8", mail.parts[0].sub_header("content-type", "charset")
    assert_equal "text/plain", mail.parts[1].content_type
    assert_equal "utf-8", mail.parts[1].sub_header("content-type", "charset")
    assert_equal "text/html", mail.parts[2].content_type
    assert_equal "utf-8", mail.parts[2].sub_header("content-type", "charset")
  end

  def test_implicitly_multipart_messages_with_custom_order
    mail = TestMailer.create_implicitly_multipart_example(@recipient, nil, ["text/yaml", "text/plain"])
    assert_equal 3, mail.parts.length
    assert_equal "text/html", mail.parts[0].content_type
    assert_equal "text/plain", mail.parts[1].content_type
    assert_equal "text/yaml", mail.parts[2].content_type
  end

  def test_implicitly_multipart_messages_with_charset
    mail = TestMailer.create_implicitly_multipart_example(@recipient, 'iso-8859-1')

    assert_equal "multipart/alternative", mail.header['content-type'].body
    
    assert_equal 'iso-8859-1', mail.parts[0].sub_header("content-type", "charset")
    assert_equal 'iso-8859-1', mail.parts[1].sub_header("content-type", "charset")
    assert_equal 'iso-8859-1', mail.parts[2].sub_header("content-type", "charset")
  end

  def test_html_mail
    mail = TestMailer.create_html_mail(@recipient)
    assert_equal "text/html", mail.content_type
  end

  def test_html_mail_with_underscores
    mail = TestMailer.create_html_mail_with_underscores(@recipient)
    assert_equal %{<a href="http://google.com" target="_blank">_Google</a>}, mail.body
  end

  def test_various_newlines
    mail = TestMailer.create_various_newlines(@recipient)
    assert_equal("line #1\nline #2\nline #3\nline #4\n\n" +
                 "line #5\n\nline#6\n\nline #7", mail.body)
  end

  def test_various_newlines_multipart
    mail = TestMailer.create_various_newlines_multipart(@recipient)
    assert_equal "line #1\nline #2\nline #3\nline #4\n\n", mail.parts[0].body
    assert_equal "<p>line #1</p>\n<p>line #2</p>\n<p>line #3</p>\n<p>line #4</p>\n\n", mail.parts[1].body
  end
  
  def test_headers_removed_on_smtp_delivery
    ActionMailer::Base.delivery_method = :smtp
    TestMailer.deliver_cc_bcc(@recipient)
    assert MockSMTP.deliveries[0][2].include?("root@loudthinking.com")
    assert MockSMTP.deliveries[0][2].include?("nobody@loudthinking.com")
    assert MockSMTP.deliveries[0][2].include?(@recipient)
    assert_match %r{^Cc: nobody@loudthinking.com}, MockSMTP.deliveries[0][0]
    assert_match %r{^To: #{@recipient}}, MockSMTP.deliveries[0][0]
    assert_no_match %r{^Bcc: root@loudthinking.com}, MockSMTP.deliveries[0][0]
  end

  def test_recursive_multipart_processing
    fixture = File.read(File.dirname(__FILE__) + "/fixtures/raw_email7")
    mail = TMail::Mail.parse(fixture)
    assert_equal "This is the first part.\n\nAttachment: test.pdf\n\n\nAttachment: smime.p7s\n", mail.body
  end

  def test_decode_encoded_attachment_filename
    fixture = File.read(File.dirname(__FILE__) + "/fixtures/raw_email8")
    mail = TMail::Mail.parse(fixture)
    attachment = mail.attachments.last
    assert_equal "01QuienTeDijat.Pitbull.mp3", attachment.original_filename
  end

  def test_wrong_mail_header
    fixture = File.read(File.dirname(__FILE__) + "/fixtures/raw_email9")
    assert_raise(TMail::SyntaxError) { TMail::Mail.parse(fixture) }
  end

  def test_decode_message_with_unknown_charset
    fixture = File.read(File.dirname(__FILE__) + "/fixtures/raw_email10")
    mail = TMail::Mail.parse(fixture)
    assert_nothing_raised { mail.body }
  end

  def test_decode_message_with_unquoted_atchar_in_header
    fixture = File.read(File.dirname(__FILE__) + "/fixtures/raw_email11")
    mail = TMail::Mail.parse(fixture)
    assert_not_nil mail.from
  end

  def test_empty_header_values_omitted
    result = TestMailer.create_unnamed_attachment(@recipient).encoded
    assert_match %r{Content-Type: application/octet-stream[^;]}, result
    assert_match %r{Content-Disposition: attachment[^;]}, result
  end

  def test_headers_with_nonalpha_chars
    mail = TestMailer.create_headers_with_nonalpha_chars(@recipient)
    assert !mail.from_addrs.empty?
    assert !mail.cc_addrs.empty?
    assert !mail.bcc_addrs.empty?
    assert_match(/:/, mail.from_addrs.to_s)
    assert_match(/:/, mail.cc_addrs.to_s)
    assert_match(/:/, mail.bcc_addrs.to_s)
  end

  def test_deliver_with_mail_object
    mail = TestMailer::create_headers_with_nonalpha_chars(@recipient)
    assert_nothing_raised { TestMailer.deliver(mail) }
    assert_equal 1, TestMailer.deliveries.length
  end
end


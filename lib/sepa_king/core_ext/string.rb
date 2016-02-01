# encoding: utf-8

# Extend String class to use I18n.transliterate as an instance method
#
# To have a better ASCII approximation for some languages, it's strongly
# recommended to add custom rules in your I18n dictionary like this
# example for Germany:
#
# de:
#   i18n:
#     transliterate:
#       rule:
#         Ä: 'Ae'
#         Ö: 'Oe'
#         Ü: 'Ue'
#         ä: 'ae'
#         ö: 'oe'
#         ü: 'ue'
#         ß: 'ss'
#
# Because this stuff is out of scope of this gem, we don't include the rules here

String.class_eval do
  def i18n_transliterate(replacement='?')
    I18n.transliterate(self, replacement)
  end
end

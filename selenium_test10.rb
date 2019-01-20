require 'selenium-webdriver'

driver = Selenium::WebDriver.for :chrome

#driver.navigate.to "https://www.e2r.jp/ja/dena2020/hs_agree.html"
#driver.navigate.to "https://www.cyberagent.co.jp/careers/students/tech/"
#driver.navigate.to "https://mypage.fjsquare.jp/ja/fujitsu2019/fsquare_kiyaku.html"
#driver.navigate.to "https://www.saiyo-dr.jp/yahoo/Entry/kiyaku.do"

driver.navigate.to "https://dwango.snar.jp/jobboard/detail.aspx"



profile_hash = {
  "氏名" => ["田中", "太郎", "タナカ", "タロウ"],
  "性別" => "男性",
  "生年月日" => ["1996", "9", "30"],
  "携帯番号" => ["090", "1111", "1111"],
  "メールアドレス" => "tanakatarou@gmail.com",
  "郵便番号" => ["123", "4567"],
  "都道府県" => "東京都",
  "市区町村" => "渋谷区宇田川町21-6",
  "マンション・アパート名" => "TSUTAYA"
}

name_key_array = ["漢字氏名", "氏名", "フリガナ氏名", "カナ氏名", "フリガナ", "カナ"]
sex_key_string = "性別"
birth_key_string = "生年月日"
phone_key_array = ["携帯番号", "携帯電話番号", "連絡先電話番号", "携帯・PHS番号"]
mail_key_array = ["連絡先メールアドレス", "E-mailアドレス", "メインメールアドレス", "メールアドレス", "携帯アドレス", "メールアドレス　(ID)"]
postal_key_string = "郵便番号"
prefecture_key_string = "都道府県"
city_key_array = ["市区郡番地", "市区町村", "市区町村・丁目・番地", "市区町村番地"]
apartment_key_array = ["アパートマンション名", "マンション・アパート名", "アパート・マンション名 部屋番号", "マンションやアパート"]
name_array = []
sex_array = []
birth_array = []
phone_array = []
mail_array = []
postal_array = []
prefecture_array = []
city_array = []
apartment_array = []

sleep 30
#-------------------------------------------------------------------------------

#ページのソースコードを取得してタグごとに配列化させる
page_source_string = driver.page_source

#</scrip>でsliceしてscriptタグが含まれているもの全て削除
tentative_source_array = page_source_string.split("</script>")
tentative_source_array = tentative_source_array.delete_if{|x| x.include?("<script>")}
page_source_string = tentative_source_array.join("")

#/div、/trで区切ってcompartment_source_arrayに追加
page_source_array = page_source_string.split(/\/div|\/tr/)

page_source_array = page_source_array.delete_if{|x| x.include?("!DOCTYPE")}

#----------------------ここ注意ーーーーーーーーーーーーーーーーーーーーーーーーー
#再入力がフォームとともにキーワードを含まず配列になっている時、１つ前の要素に付け足す
page_source_array.each_with_index{|source, index|
if source.include?("再入力") || source.include?("再度入力")
  page_source_array[index-1] += source
end
}
#上の処理後、追加された要素を削除する
page_source_array.delete_if.with_index{|source, index| page_source_array[index-1].include?(source)}

#フォームがあるがキーワードを１つも含まない時は１つ前の要素に付け足す。（2個先までしか対応していない！！）
whole_key = ["自宅電話", "漢字氏名", "氏名", "フリガナ氏名", "カナ氏名", "フリガナ", "カナ", "性別", "生年月日", "携帯番号", "携帯電話番号", "連絡先電話番号", "連絡先メールアドレス", "E-mailアドレス", "メインメールアドレス", "メールアドレス", "携帯アドレス", "郵便番号", "都道府県", "市区郡番地", "市区町村", "市区町村・丁目・番地", "市区町村番地", "アパートマンション名", "マンション・アパート名", "アパート・マンション名 部屋番号"]
page_source_array.each_with_index{|source, index|
if source.include?(%Q(type=\"text\")) && whole_key.any?{|key| source.include?(key)} == false
  page_source_array[index-1] += source
  if page_source_array[index+1].include?(%Q(type=\"text\")) && whole_key.any?{|key| page_source_array[index+1].include?(key)} == false
    page_source_array[index-1] += source
  end
end
}

#-------------------------------------------------------------------------------

#キーワードに引っかかる文字列を含む要素を配列化
page_source_array.each{|source|
#氏名欄取得
name_key_array.each{|name|
if source.include?(name)
  name_array.push(source)
end
}
#性別欄取得
if source.include?(sex_key_string)
  sex_array.push(source)
end
#生年月日欄取得
if source.include?(birth_key_string)
  birth_array.push(source)
end
#電話番号欄取得
phone_key_array.each{|phone|
if source.include?(phone)
  phone_array.push(source)
end
}
#メールアドレス欄取得
mail_key_array.each{|mail|
if source.include?(mail)
  mail_array.push(source)
end
}
#郵便番号欄取得
if source.include?(postal_key_string)
  postal_array.push(source)
end
#都道府県欄取得
if source.include?(prefecture_key_string)
  prefecture_array.push(source)
end
#市区町村欄取得
city_key_array.each{|city|
if source.include?(city)
  city_array.push(source)
end
}
#アパートマンション名欄取得
apartment_key_array.each{|apartment|
if source.include?(apartment)
  apartment_array.push(source)
end
}
}

#配列の要素を１つにして、タグごとに分ける
name_array = name_array.join("").split(/[<|>]/).uniq!
sex_array = sex_array.join("").split(/[<|>]/).uniq!
birth_array = birth_array.join("").split(/[<|>]/).uniq!
phone_array = phone_array.join("").split(/[<|>]/).uniq!
mail_array = mail_array.join("").split(/[<|>]/).uniq!
postal_array = postal_array.join("").split(/[<|>]/).uniq!
prefecture_array = prefecture_array.join("").split(/[<|>]/).uniq!
city_array = city_array.join("").split(/[<|>]/).uniq!
apartment_array = apartment_array.join("").split(/[<|>]/).uniq!

#------------------------------------注意-----------------------------------------------------
#氏名欄の上に「メールアドレス」というキーワードが含まれた説明欄がある⇨name_arrayが説明欄も含んでしまう
#mail_arrayのなかにname_arrayの要素が入ってしまうサイトがあったため、ここではmail_arrayから被ったものを削除。
name_array.each{|name_source|
mail_array.delete_if{|mail_source| mail_source == name_source}
}

#-------------------------------------------------------------------------------

#氏名欄の入力フォームのnameを取得
name_name_array = []
name_array.each{|source|
if source.include?(%Q(type=\"text\"))
  if /name="(.*?)"/ =~ source
    name_name_array.push($1)
  end
end
}
#氏名入力
if name_name_array.length == 4
  for i in 0..3
    driver.find_element(:name, name_name_array[i]).send_keys profile_hash["氏名"][i]
  end
end

#-------------------------------------------------------------------------------

#性別欄取得
sex_name_array = []
#ラジオタイプならsex_method=1、セレクトタイプならsex_method=2
sex_method = 0
if sex_array != nil
  sex_array.each{|source|
  if source.include?(%Q(type=\"radio\"))
    /name="(.*?)"/ =~ source
    sex_method = 1
    sex_name_array.push($1)
  elsif source.include?("select")
    /name="(.*?)"/ =~ source
    sex_method = 2
    sex_name_array.push($1)
  end
  }
end

#sex_name_arrayは１つでななく同じのがあるため
if sex_name_array != nil
  sex_name_array.uniq!
end

#性別欄入力
#ラジオボタンタイプの時
if sex_method == 1
  sex_button_array = []
  elements = driver.find_elements(:tag_name, "input")
  elements.each{|element|
  if element.attribute("name") == sex_name_array[0]
    sex_button_array.push(element)
  end
  }
end
if sex_method == 1
  if profile_hash["性別"] == "男性"
    sex_button_array[0].click
  elsif profile_hash["性別"] == "女性"
    sex_button_array[1].click
  end
end
#セレクトタイプの時
if sex_method == 2
  select = Selenium::WebDriver::Support::Select.new(driver.find_element(:name, sex_name_array[0]))
  select.select_by(:text, profile_hash["性別"])
end

#-------------------------------------------------------------------------------

#生年月日欄取得
birth_name_array = []
#テキストタイプならbirth_method=1、セレクトタイプならbirth_method=2
birth_method = 0
birth_array.each{|source|
if source.include?(%Q(type=\"text\"))
  /name="(.*?)"/ =~ source
  birth_method = 1
  birth_name_array.push($1)
elsif source.include?("select")
  /name="(.*?)"/ =~ source
  birth_method = 2
  birth_name_array.push($1)
end
}

birth_name_array.delete_if{|x| x == nil}

#生年月日欄入力
#テキストタイプの時
if birth_method == 1 && birth_name_array.length == 3
  for i in 0..2
    driver.find_element(:name, birth_name_array[i]).send_keys profile_hash["生年月日"][i]
  end
end
#セレクトタイプの時
if birth_method == 2 && birth_name_array.length == 3
  for i in 0..2
    select = Selenium::WebDriver::Support::Select.new(driver.find_element(:name, birth_name_array[i]))
    begin
      select.select_by(:text, profile_hash["生年月日"][i])
    rescue
      select.select_by(:text, "0"+profile_hash["生年月日"][i])
    end
  end
end

#-------------------------------------------------------------------------------
#携帯番号欄取得
phone_name_array = []
if phone_array&.length != nil
  phone_array.each{|source|
  if source.include?(%Q(type=\"text\"))
    if /name="(.*?)"/ =~ source
      phone_name_array.push($1)
    end
  end
  }
end

#携帯番号入力
if phone_name_array.length == 1
  driver.find_element(:name, phone_name_array[0]).send_keys profile_hash["携帯番号"][0]+"-"+profile_hash["携帯番号"][1]+"-"+profile_hash["携帯番号"][2]
elsif phone_name_array.length > 1
  for i in 0..2
    driver.find_element(:name, phone_name_array[i]).send_keys profile_hash["携帯番号"][i]
  end
end

#-------------------------------------------------------------------------------
#メールアドレス欄取得
mail_name_array = []
mail_array.each{|source|
if source.include?(%Q(type=\"text\"))
  if /name="(.*?)"/ =~ source
    mail_name_array.push($1)
  end
end
}
#メールアドレス入力
if mail_name_array.length == 1
  driver.find_element(:name, mail_name_array[0]).send_keys profile_hash["メールアドレス"]
elsif mail_name_array.length == 2
  driver.find_element(:name, mail_name_array[0]).send_keys profile_hash["メールアドレス"]
  driver.find_element(:name, mail_name_array[1]).send_keys profile_hash["メールアドレス"]
elsif mail_name_array.length == 4
  driver.find_element(:name, mail_name_array[0]).send_keys profile_hash["メールアドレス"]
  driver.find_element(:name, mail_name_array[1]).send_keys profile_hash["メールアドレス"]
end

#-------------------------------------------------------------------------------
#郵便番号欄取得
postal_name_array = []
if postal_array != nil
  postal_array.each{|source|
  if source.include?(%Q(type=\"text\"))
    if /name="(.*?)"/ =~ source
      postal_name_array.push($1)
    end
  end
  }
end

#氏名入力
if postal_name_array.empty? == false
  for i in 0..1
    driver.find_element(:name, postal_name_array[i]).send_keys profile_hash["郵便番号"][i]
  end
end
#-------------------------------------------------------------------------------
#都道府県欄取得
prefecture_name_array = []
if prefecture_array&.length != nil
  prefecture_array.each{|source|
  if source.include?("select")
    if /name="(.*?)"/ =~ source
      prefecture_name_array.push($1)
    end
  end
  }
end
p prefecture_name_array
#セレクトタイプ入力
if prefecture_name_array&.length == 1
  select = Selenium::WebDriver::Support::Select.new(driver.find_element(:name, prefecture_name_array[0]))
  select.select_by(:text, profile_hash["都道府県"])
end

#-------------------------------------------------------------------------------
#市区町村欄入力
city_name_array = []
if city_array&.length != nil
  city_array.each{|source|
  if source.include?(%Q(type=\"text\"))
    if /name="(.*?)"/ =~ source
      city_name_array.push($1)
    end
  end
  }
end
#市区町村入力
if city_name_array.empty? == false
  driver.find_element(:name, city_name_array[0]).send_keys profile_hash["市区町村"]
end

#-------------------------------------------------------------------------------
#マンションアパート名欄入力
apartment_name_array = []
if apartment_array&.length != nil
  apartment_array.each{|source|
  if source.include?(%Q(type=\"text\"))
    if /name="(.*?)"/ =~ source
      apartment_name_array.push($1)
    end
  end
  }
end
#市区町村入力
if apartment_name_array.empty? == false
  driver.find_element(:name, apartment_name_array[0]).send_keys profile_hash["マンション・アパート名"]
end
sleep 10000

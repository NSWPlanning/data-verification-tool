ActiveRecord::Base.logger = Logger.new(STDOUT)

admin = User.new  :name => 'Admin User', :email => 'admin@example.com',
                  :password => 'password', :password_confirmation => 'password'
admin.roles = [:admin]
admin.save!

{
  'Albury' => nil,
  'Armidale Dumaresq' => nil,
  'Ashfield' => nil,
  'Auburn' => nil,
  'Ballina' => nil,
  'Balranald' => nil,
  'Bankstown' => nil,
  'Bathurst Regional' => nil,
  'Baulkham Hills' => nil,
  'Bega Valley' => nil,
  'Bellingen' => nil,
  'Berrigan' => nil,
  'Blacktown' => nil,
  'Bland' => nil,
  'Blayney' => nil,
  'Blue Mountains' => nil,
  'Bogan' => nil,
  'Bombala' => nil,
  'Boorowa' => nil,
  'Botany Bay' => nil,
  'Bourke' => nil,
  'Brewarrina' => nil,
  'Broken Hill' => nil,
  'Burwood' => nil,
  'Byron' => nil,
  'Cabonne' => nil,
  'Camden' => nil,
  'Campbelltown' => nil,
  'Canada Bay' => nil,
  'Canterbury' => nil,
  'Carrathool' => nil,
  'Central Darling' => nil,
  'Cessnock' => nil,
  'Clarence Valley' => nil,
  'Cobar' => nil,
  'Coffs Harbour' => nil,
  'Conargo' => nil,
  'Coolamon' => nil,
  'Cooma-Monaro' => nil,
  'Coonamble' => nil,
  'Cootamundra' => nil,
  'Corowa' => nil,
  'Cowra' => nil,
  'Deniliquin' => nil,
  'Dubbo' => nil,
  'Dungog' => nil,
  'Eurobodalla' => nil,
  'Fairfield' => nil,
  'Forbes' => nil,
  'Gilgandra' => nil,
  'Glen Innes Severn Shire' => nil,
  'Gloucester' => nil,
  'Gosford' => nil,
  'Goulburn Mulwaree' => nil,
  'Great Lakes' => nil,
  'Greater Hume' => nil,
  'Greater Taree' => nil,
  'Griffith' => nil,
  'Gundagai' => nil,
  'Gunnedah' => nil,
  'Guyra' => nil,
  'Gwydir' => nil,
  'Harden' => nil,
  'Hawkesbury' => nil,
  'Hay' => nil,
  'Holroyd' => nil,
  'Hornsby' => nil,
  'Hunters Hill' => nil,
  'Hurstville' => nil,
  'Inverell' => nil,
  'Jerilderie' => nil,
  'Junee' => nil,
  'Kempsey' => nil,
  'Kiama' => nil,
  'Kogarah' => 'CITY OF KOGARAH',
  'Ku-Ring-Gai' => nil,
  'Kyogle' => nil,
  'Lachlan' => nil,
  'Lake Macquarie' => nil,
  'Lane Cove' => nil,
  'Leeton' => nil,
  'Leichhardt' => nil,
  'Lismore' => nil,
  'Lithgow' => nil,
  'Liverpool' => nil,
  'Liverpool Plains' => nil,
  'Lockhart' => nil,
  'Maitland' => nil,
  'Manly' => nil,
  'Marrickville' => nil,
  'Mid-Western Regional' => nil,
  'Moree Plains' => nil,
  'Mosman' => nil,
  'Murray' => nil,
  'Murrumbidgee' => nil,
  'Muswellbrook' => nil,
  'Nambucca' => nil,
  'Narrabri' => nil,
  'Narrandera' => nil,
  'Narromine' => nil,
  'Newcastle' => nil,
  'North Sydney' => nil,
  'Oberon' => nil,
  'Orange' => nil,
  'Palerang' => nil,
  'Parkes' => nil,
  'Parramatta' => nil,
  'Penrith' => nil,
  'Pittwater' => nil,
  'Port Macquarie-Hastings' => nil,
  'Port Stephens' => nil,
  'Queanbeyan City' => nil,
  'Randwick' => nil,
  'Richmond Valley' => nil,
  'Rockdale' => nil,
  'Ryde' => nil,
  'Shellharbour' => nil,
  'Shoalhaven' => nil,
  'Singleton' => nil,
  'Snowy River' => nil,
  'Strathfield' => nil,
  'Sutherland' => 'SUTHERLAND SHIRE',
  'Sydney' => nil,
  'Tamworth Regional' => nil,
  'Temora' => nil,
  'Tenterfield' => nil,
  'Tumbarumba' => nil,
  'Tumut' => nil,
  'Tweed' => nil,
  'Unincorporated' => nil,
  'Upper Hunter' => nil,
  'Upper Lachlan Shire' => nil,
  'Uralla' => nil,
  'Urana' => nil,
  'Wagga Wagga' => nil,
  'Wakool' => nil,
  'Walcha' => nil,
  'Walgett' => nil,
  'Warren' => nil,
  'Warringah' => nil,
  'Warrumbungle' => nil,
  'Waverley' => nil,
  'Weddin' => nil,
  'Wellington' => nil,
  'Wentworth' => nil,
  'Willoughby' => nil,
  'Wingecarribee' => nil,
  'Wollondilly' => nil,
  'Wollongong' => nil,
  'Woollahra' => nil,
  'Wyong' => nil,
  'Yass Valley' => nil,
  'Young' => nil
}.map do |lga_name, lga_alias|
  lga_alias = lga_alias || lga_name.upcase
  LocalGovernmentArea.create! :name => lga_name, :alias => lga_alias
end

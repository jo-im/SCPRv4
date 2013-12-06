# encoding: utf-8
class VerticalSeed < ActiveRecord::Migration
  def up
    category = Category.find(5)


    issue1 = Issue.create! is_active: true, slug: "reform", title: "Reform", description: "There are many organizations and individuals dedicated to making government at all levels more responsive and transparent. Governments themselves sometimes initiate these efforts."
    issue2 = Issue.create! is_active: true, slug: "money", title: "Money", description: "The axiom “Follow the money” applies to all levels of government and elections. We’ll track spending and donations."
    issue3 = Issue.create! is_active: true, slug: "immigration", title: "Immigration", description: "The U.S. Congress continues to consider legislation to amend the nation’s immigration laws."
    issue4 = Issue.create! is_active: true, slug: "dwp", title: "DWP", description: "The Los Angeles Department of Water and Power is one of the country’s largest utilities, serving 3.9 million customers."
    issue5 = Issue.create! is_active: true, slug: "calderon", title: "Calderon investigation", description: "State Senator Ron Calderon (D-Montebello) is under investigation by the U.S. Department of Justice. He and other elected officials and public agencies have been served with subpoenas."
    issue6 = Issue.create! is_active: true, slug: "2014-election", title: "2014 Election", description: "The mid-term elections will include all seats in the U.S. House of Representatives. Californians will vote for Governor, Attorney General and other statewide offices. Even-numbered districts in the state Senate will be on the ballot, as will all seats in the Assembly.  In Los Angeles County, there will be elections for seats on the Board of Supervisors and for County Sheriff. The primary is June 3rd and the runoff is November 4th."
    issue7 = Issue.create! is_active: true, slug: "project-citizen", title: "Project Citizen", description: "This KPCC series looks at the rights, responsibilities, traditions and privileges that come with being a citizen."

    category.issues = [issue1, issue2, issue3]


    quote = Quote.create! category_id: category.id, source_name: "Chris Isaac Brown", source_context: "New Mayor of Hawthorne", content_type: "BlogEntry", content_id: 15315, status: Quote::STATUS_LIVE, quote: "Hawthorne has endless potential, [but] it doesn't have one major restaurant or store."


    article1 = ContentBase.obj_by_url! "http://www.scpr.org/blogs/politics/2013/12/05/15332/congressional-midterm-campaigns-underway-who-s-got/"
    article2 = ContentBase.obj_by_url! "http://www.scpr.org/news/2013/09/05/39065/los-angeles-neighborhood-council-faq-map/"
    article3 = ContentBase.obj_by_url! "http://www.scpr.org/blogs/multiamerican/2013/07/03/14170/projectcitizen-would-you-pass-the-citizenship-test/"
    article4 = Outpost.obj_by_key! "content_shell-511"
    article5 = Outpost.obj_by_key! "content_shell-512"
    article6 = Outpost.obj_by_key! "content_shell-510"

    category.category_articles.create!(article: article1)
    category.category_articles.create!(article: article2)
    category.category_articles.create!(article: article3)
    category.category_articles.create!(article: article4)
    category.category_articles.create!(article: article5)
    category.category_articles.create!(article: article6)


    bio1 = Bio.find_by_name!("Kitty Felde")
    bio2 = Bio.find_by_name!("Julie Small")
    bio3 = Bio.find_by_name!("Frank Stoltze")
    bio4 = Bio.find_by_name!("Sharon McNary")
    bio5 = Bio.find_by_name!("Alice Walton")
    bio6 = Bio.find_by_name!("Oscar Garza")

    category.bios = [bio1, bio2, bio3, bio4, bio5, bio6]


    event1 = Event.find(1265)
    event2 = Event.find(1266)
    event3 = Event.find(1267)

    event1.update_attributes(category_id: category.id)
    event2.update_attributes(category_id: category.id)
    event3.update_attributes(category_id: category.id)


    [
      "http://www.scpr.org/blogs/politics/2013/12/02/15290/san-bernardino-portrait-of-residents-of-a-problem/",
      "http://www.scpr.org/blogs/politics/2013/10/29/15082/pension-reform-long-beach-claims-leadership-in-red/",
      "http://www.scpr.org/blogs/politics/2013/10/23/15048/new-website-opens-los-angeles-financial-books-to-t/",
      "http://www.scpr.org/blogs/politics/2013/10/17/15008/former-la-mayor-texas-mogul-back-statewide-pension/",
      "http://www.scpr.org/blogs/politics/2013/10/16/14988/los-angeles-to-tackle-voter-apathy-in-city-electio/",
      "http://www.scpr.org/blogs/politics/2013/10/15/14982/ca-mayors-want-voters-to-let-cities-cut-public-pen/",
      "http://www.scpr.org/blogs/politics/2013/10/08/14924/gov-brown-signs-bill-enforcing-transparency-on-may/",
      "http://www.scpr.org/blogs/politics/2013/10/01/14870/la-city-council-moves-to-redefine-neighborhood-cou/"
    ].each { |u| ContentBase.obj_by_url!(u).issues << issue1 }

    [
      "http://www.scpr.org/blogs/politics/2013/12/05/15332/congressional-midterm-campaigns-underway-who-s-got/",
      "http://www.scpr.org/blogs/politics/2013/11/22/15257/maven-s-morning-coffee-jerry-brown-fundraises-park/",
      "http://www.scpr.org/blogs/politics/2013/11/13/15188/the-atm-effect-la-s-the-place-for-campaign-cash/",
      "http://www.scpr.org/news/2013/11/08/40275/magic-johnson-to-host-president-obama-at-la-fundra/",
      "http://www.scpr.org/news/2013/11/05/40206/official-moreno-valley-city-councilman-to-plead-gu/",
      "http://www.scpr.org/news/2013/10/25/40023/ready-for-hillary-superpac-gains-backing-from-bill/"
    ].each { |u| ContentBase.obj_by_url!(u).issues << issue2 }

    [
      "http://www.scpr.org/blogs/politics/2013/11/01/15106/the-pressure-s-on-california-house-gop-members-to/",
      "http://www.scpr.org/blogs/politics/2013/10/30/15098/valadao-is-second-ca-gop-congressman-to-co-sponsor/",
      "http://www.scpr.org/blogs/politics/2013/11/15/15205/immigration-reform-ca-gop-members-not-giving-up/",
      "http://www.scpr.org/blogs/politics/2013/11/20/15238/immigration-reform-house-s-piecemeal-approach-coul/",
      "http://www.scpr.org/blogs/politics/2013/10/10/14949/immigration-poll-puts-pressure-on-central-valley-l/",
      "http://www.scpr.org/blogs/politics/2013/10/07/14914/growers-push-california-gop-on-immigration/",
      "http://www.scpr.org/blogs/politics/2013/10/02/14881/house-democrats-unveil-their-own-immigration-bill/"
    ].each { |u| ContentBase.obj_by_url!(u).issues << issue3 }

    [
      "http://www.scpr.org/blogs/politics/2013/11/27/15294/dwp-explains-billing-problems-to-los-angeles-city/",
      "http://www.scpr.org/blogs/politics/2013/11/19/15226/dwp-board-requests-audit-of-union-linked-nonprofit/",
      "http://www.scpr.org/blogs/politics/2013/10/17/14998/dwp-commission-allows-trusts-to-hire-internal-audi/",
      "http://www.scpr.org/blogs/politics/2013/10/01/14873/new-dwp-commissioners-demand-documents-on-nonprofi/"
    ].each { |u| ContentBase.obj_by_url!(u).issues << issue4 }

    [
      "http://www.scpr.org/blogs/politics/2013/11/13/15193/calderon-says-fbi-asked-him-to-secretly-record-sen/",
      "http://www.scpr.org/blogs/politics/2013/11/13/15186/local-elected-leaders-call-on-calderon-to-resign/",
      "http://www.scpr.org/blogs/politics/2013/11/08/15151/ron-calderon-lashes-out-at-assemblywoman-who-calle/"
    ].each { |u| ContentBase.obj_by_url!(u).issues << issue5 }

    [
      "http://www.scpr.org/blogs/politics/2013/12/03/15311/candidates-lining-up-for-mckeon-s-congressional-se/",
      "http://www.scpr.org/blogs/politics/2013/11/26/15283/2014-election-ventura-county-incumbent-congresswom/",
      "http://www.scpr.org/blogs/politics/2013/11/12/15170/as-parties-look-to-2014-elections-and-beyond-what/",
      "http://www.scpr.org/blogs/politics/2013/11/11/15159/assemblyman-mike-morrell-to-run-in-vacated-inland/",
      "http://www.scpr.org/blogs/politics/2013/11/21/15251/races-for-la-county-board-of-supervisors-who-s-in/",
      "http://www.scpr.org/blogs/politics/2013/11/15/15201/lottery-offers-president-obama-and-magic-johnson-a/",
      "http://www.scpr.org/blogs/politics/2013/10/09/14940/assembly-speaker-announces-run-for-state-controlle/"
    ].each { |u| ContentBase.obj_by_url!(u).issues << issue6 }


    [
      "http://www.scpr.org/blogs/politics/2013/11/15/15198/talk-to-city-council-from-the-comfort-of-your-couc/",
      "http://www.scpr.org/blogs/politics/2013/11/06/15129/would-be-candidates-get-a-boost-onto-the-political/"
    ].each { |u| ContentBase.obj_by_url!(u).issues << issue7 }
  end

  def down
    Issue.destroy_all
    Quote.destroy_all
    Event.update_all(category_id: nil)
  end
end

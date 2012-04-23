require 'spec_helper'

describe "Static pages" do

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_selector('h1',    text: heading) }
    it { should have_selector('title', text: full_title(page_title)) }
  end

  describe "Home page" do
    before { visit root_path }
    let(:heading)    { 'Sample App' }
    let(:page_title) { 'Home' }

    it_should_behave_like "all static pages"
    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
        sign_in user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          page.should have_selector("li##{item.id}", text: item.content)
        end
      end

      describe "follower/following counts" do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
          other_user.follow!(user)
          visit root_path
        end

        it { should have_link("0 following", href: following_user_path(user)) }
        it { should have_link("1 follower",  href: followers_user_path(user)) }
      end

      describe "should count microposts" do
        it {should have_selector("span", text: "2 microposts")}
        
        describe "should pluralize" do
          before {click_link('delete')}
          it {should have_selector("span", text: "1 micropost")}
        end
      end

      describe "should paginate" do
        before(:all) {60.times {FactoryGirl.create(:micropost, user: user)}}
        after(:all) {Micropost.delete_all}

        let(:first_page)  { Micropost.paginate(page: 1) }
        let(:second_page) { Micropost.paginate(page: 2) }
        it { should have_link('Next') }
        its(:html) { should match('>2</a>') }

        it "should list each micropost" do
          Micropost.all[0..2].each do |micropost|
            page.should have_content(micropost.content)
          end
        end

        it "should list the first page of microposts" do
          first_page.each do |micropost|
            page.should have_content(micropost.content)
          end
        end

        it "should not list the second page of microposts" do
          second_page.each do |micropost|
            page.should_not have_content(micropost.content)
          end
        end

        describe "showing the second page" do
          before { visit root_path(page: 2) }

          it "should list the second page of microposts" do
            second_page.each do |micropost|
              page.should have_content(micropost.content)
            end 
          end
        end
      end
    end
  end

  describe "Help page" do
    before { visit help_path }
    let(:heading)     { 'Help' }
    let(:page_title)  { 'Help' }

    it_should_behave_like "all static pages"
  end

  describe "About page" do
    before { visit about_path }
    let(:heading)    {'About'}
    let(:page_title) {'About Us'}
    
    it_should_behave_like "all static pages"
  end

  describe "Contact page" do
    before { visit contact_path }

    let(:heading)    {'Contact'}
    let(:page_title) {'Contact'}

    it_should_behave_like "all static pages"   
  end

  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    page.should have_selector 'title', text: full_title('About Us')
    click_link "Help"
    page.should have_selector 'title', text: full_title('Help')
    click_link "Contact"
    page.should have_selector 'title', text: full_title('Contact')
    click_link "Home"
    page.should have_selector 'title', text: full_title('Home')
    click_link "Sign up now!"
    page.should have_selector 'title', text: full_title('Sign up')
  end
end
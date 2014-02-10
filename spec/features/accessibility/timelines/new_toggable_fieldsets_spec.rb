#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2013 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

require 'spec_helper'
require 'features/accessibility/support/toggable_fieldsets_spec'
require 'features/timelines/timelines_page'

describe 'Timelines' do
  describe 'edit' do
    describe 'Toggable fieldset' do
      let(:project) { FactoryGirl.create(:project) }
      let(:current_user) { FactoryGirl.create (:admin) }
      let(:timelines_page) { TimelinesPage.new(project) }

      before do
        User.stub(:current).and_return current_user

        timelines_page.visit_new
      end

      describe 'General settings fieldset' do
        it_behaves_like 'toggable fieldset initially collapsed' do
          let(:fieldset_name) { 'General Settings' }
        end
      end

      describe 'Comparisons fieldset' do
        it_behaves_like 'toggable fieldset initially expanded' do
          let(:fieldset_name) { 'Comparisons' }
        end
      end

      describe 'Vertical work packages fieldset' do
        it_behaves_like 'toggable fieldset initially expanded' do
          let(:fieldset_name) { 'Vertical work packages' }
        end
      end

      describe 'Filter work packages fieldset' do
        it_behaves_like 'toggable fieldset initially expanded' do
          let(:fieldset_name) { 'Filter work packages' }
        end
      end

      describe 'Filter projects fieldset' do
        it_behaves_like 'toggable fieldset initially expanded' do
          let(:fieldset_name) { 'Filter projects' }
        end
      end

      describe 'Grouping fieldset' do
        it_behaves_like 'toggable fieldset initially expanded' do
          let(:fieldset_name) { 'Grouping' }
        end
      end
    end
  end
end

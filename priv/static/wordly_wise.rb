#!/usr/bin/ruby

require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'pry'

Capybara.default_driver = :poltergeist
Capybara.javascript_driver = :poltergeist
Capybara.app_host = 'https://50.23.224.213'
Capybara.run_server = false

class WordlyWise
  include Capybara::DSL

  SCHOOL_ID = ENV['WW_SCHOOL_ID']
  SCHOOL = ENV['WW_SCHOOL']
  USERNAME = ENV['WW_USERNAME']
  PASSWORD = ENV['WW_PASSWORD']

  def login!
    visit '/academy/ProcessMngLogin.do?database=db01'
    select(SCHOOL, from: 'schoolId')
    fill_in 'loginUsername', with: USERNAME
    fill_in 'tempLoginPassword', with: PASSWORD
    find(:css, 'div.button_login').click
  end

  def generate_report(username)
    JSON.generate(save_report(username))
  end

  def save_report(name)
    load_normal_activities(name) + load_test_activities(name)
  end

  def load_normal_activities(name)
    # filename = name.gsub(' ', '-').gsub(',', '').downcase + '-' + Time.now.strftime('%Y-%m-%d_%H-%M-%S') + '.png'
    visit '/academy/reportui/ReportFrames.htm?startPage=STWW3000SnapshotR'
    activities = []
    within_content do
      select_student_id(name)
      level = select_last_level
      lessons = page.evaluate_script("$('[name=lessonName] option').map(function(opt) { return this.value }).get()")[1..-1]
      select lessons.last, from: 'lessonName'
      sleep 1
      activities.concat(json_data(name, lessons.last.to_i, level))
    end
    activities
  end

  def load_test_activities(name)
    visit '/academy/reportui/ReportFrames.htm?startPage=STWW3000TestResults'
    activities = []
    within_content do
      select_student_id(name)
      level = select_last_level
      activities.concat(json_test_data(name, level))
    end
    activities
  end

  private
  def within_content(&block)
    within_frame(find('[name=content]')) { block.call() }
  end

  def select_student_id(name)
    select name, from: 'studentId'
    sleep 1
  end

  def select_last_level
    last_selectable_level = page.evaluate_script("$('[name=streamGroupName] option:last').text()")
    if last_selectable_level.empty?
      last_selectable_level = /level.\s(\d+)/i.match(page.text)[1].to_f
    else
      select last_selectable_level, from: 'streamGroupName'
      last_selectable_level = last_selectable_level.to_f
      sleep 1
    end
    sleep 1
    last_selectable_level
  end

  def json_data(name, lesson, level)
    grade = find_grade
    rows = find_text_of_rows
    rows.map do |row|
      {
        name: name,
        grade: grade,
        lesson: lesson,
        level: level,
        activity: row[0],
        seconds: duration_to_seconds(row[1]),
        score: percent_to_score(row[2])
      }
    end
  end

  def json_test_data(name, level)
    grade = find_grade
    rows = find_text_of_rows
    recursive_process_test_row(rows[0], rows[1..-1], []).map do |data|
      data.merge({name: name, grade: grade, level: level})
    end
  end

  def recursive_process_test_row(row, rows, output)
    return output unless row
    recursive_process_test_row(
      rows[0],
      rows[1..-1],
      output + [pre_test(row), post_test(row)].compact
    )
  end

  def pre_test(row)
    if row[1] != '---'
      {
        activity: 'Pre-Test',
        lesson: parse_lesson(row[0]),
        seconds: duration_to_seconds(row[1], true),
        score: percent_to_score(row[2]),
        date: Date.parse(row[3])
      }
    else
      nil
    end
  end

  def post_test(row)
    if row[4] != '---'
      {
        activity: 'Post-Test',
        lesson: parse_lesson(row[0]),
        seconds: duration_to_seconds(row[4], true),
        score: percent_to_score(row[5]),
        date: Date.parse(row[6])
      }
    else
      nil
    end
  end

  def find_grade
    /grade.\s*(\d+)/i.match(page.text)[1].to_i
  end

  def find_text_of_rows
    all('#_sortableTable tbody tr').map do |e|
      within(e) do
        all('td').map(&:text)
      end
    end
  end

  def parse_lesson(lesson_description)
    regex = /Lesson (?<lesson>\d+)/
    match_data = regex.match(lesson_description)
    if match_data
      match_data['lesson'].to_i
    else
      throw "Cannot extract lesson from description: #{lesson_description}"
    end
  end

  def duration_to_seconds(duration, compact=false)
    regex = compact ? /(?<min>\d+):(?<sec>\d+)/ : /(?<min>\d+) min (?<sec>\d+) sec/
    match_data = regex.match(duration)
    if match_data
      match_data['min'].to_i * 60 + match_data['sec'].to_i
    else
      0
    end
  end

  def percent_to_score(percent)
    regex = /(?<percent>\d+)%/
    match_data = regex.match(percent)
    if match_data
      match_data['percent'].to_i
    else
      0
    end
  end
end

instance = WordlyWise.new
instance.login!
puts instance.generate_report(ARGV.first)

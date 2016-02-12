require 'spec_helper'

describe Jkf::Parser::Ki2 do
  let(:ki2_parser) { Jkf::Parser::Ki2.new }
  subject { ki2_parser.parse(str) }

  shared_examples(:parse_file) do |filename|
    let(:str) do
      if File.extname(filename) == '.ki2'
        File.read(filename, encoding: 'Shift_JIS').toutf8
      else
        File.read(filename).toutf8
      end
    end
    it "should be parse #{File.basename(filename)}" do
      is_expected.not_to be_nil
    end
  end

  fixtures(:ki2).each do |fixture|
    it_behaves_like :parse_file, fixture
  end

  context 'simple' do
    let(:str) { "▲７六歩 △３四歩 ▲２二角成 △同　銀 ▲４五角" }

    it {
      is_expected.to eq Hash[
        header:{},
        moves:[
          {},
          {move:{to:pos(7,6),piece:"FU"}},
          {move:{to:pos(3,4),piece:"FU"}},
          {move:{to:pos(2,2),piece:"KA",promote:true}},
          {move:{same:true,piece:"GI"}},
          {move:{to:pos(4,5),piece:"KA"}},
        ]
      ]
    }
  end

  context 'special' do
    let(:str) { "▲７六歩 △３四歩 ▲７八銀 △８八角成\nまで4手で後手の勝ち\n" }

    it {
      is_expected.to eq Hash[
        header:{},
        moves:[
          {},
          {move:{to:pos(7,6),piece:"FU"}},
          {move:{to:pos(3,4),piece:"FU"}},
          {move:{to:pos(7,8),piece:"GI"}},
          {move:{to:pos(8,8),piece:"KA",promote:true}},
          {special:"TORYO"},
        ]
      ]
    }
  end

  describe 'header' do
    context '手合割 平手' do
      let(:str) { "手合割：平手\n▲７六歩 △３四歩 ▲２二角成 △同　銀 ▲４五角" }

      it {
        is_expected.to eq Hash[
          header:{
            "手合割" => "平手",
          },
          initial: {preset: "HIRATE"},
          moves:[
            {},
            {move:{to:pos(7,6),piece:"FU"}},
            {move:{to:pos(3,4),piece:"FU"}},
            {move:{to:pos(2,2),piece:"KA",promote:true}},
            {move:{same:true,piece:"GI"}},
            {move:{to:pos(4,5),piece:"KA"}},
          ]
        ]
      }
    end

    context '手合割 六枚落ち' do
      let(:str) { "手合割：六枚落ち\n△４二玉 ▲７六歩 △２二銀 ▲６六角 △８二銀" }

      it {
        is_expected.to eq Hash[
          header:{
            "手合割" => "六枚落ち",
          },
          initial: {preset: "6"},
          moves:[
            {},
            {move:{to:pos(4,2),piece:"OU"}},
            {move:{to:pos(7,6),piece:"FU"}},
            {move:{to:pos(2,2),piece:"GI"}},
            {move:{to:pos(6,6),piece:"KA"}},
            {move:{to:pos(8,2),piece:"GI"}},
          ]
        ]
      }
    end
  end

  describe 'initial' do
    context 'simple' do
      let(:str) { "\
手合割：その他　\n\
上手の持駒：銀四　桂四　\n\
  ９ ８ ７ ６ ５ ４ ３ ２ １\n\
+---------------------------+\n\
| ・ ・ ・ ・ ・ ・ ・v歩v玉|一\n\
| ・ ・ ・ ・ ・ ・ ・v歩 ・|二\n\
| ・ ・ ・ ・ ・ ・ ・v歩 ・|三\n\
| ・ ・ ・ ・ ・ ・ ・v歩 ・|四\n\
| ・ ・ ・ ・ ・ ・ ・v歩 ・|五\n\
| ・ ・ ・ ・ ・ ・ ・v歩 ・|六\n\
| ・ ・ ・ ・ ・ ・ ・v歩 ・|七\n\
| ・ ・ ・ ・ ・ ・ ・v歩 ・|八\n\
| ・ ・ ・ ・ ・ ・ ・v歩 ・|九\n\
+---------------------------+\n\
下手の持駒：飛二　香四　\n\
下手番\n\
下手：shitate\n\
上手：uwate\n\
▲１三香 △１二桂 ▲同香成"
      }

      it {
        is_expected.to eq Hash[
          header:{
            "手合割" => "その他　",
            "上手" => "uwate",
            "下手" => "shitate",
          },
          initial: {
            preset:"OTHER",
            data:{
              board:[
                [{color:1,kind:"OU"},{},{},{},{},{},{},{},{}],
                [{color:1,kind:"FU"},{color:1,kind:"FU"},{color:1,kind:"FU"},{color:1,kind:"FU"},{color:1,kind:"FU"},{color:1,kind:"FU"},{color:1,kind:"FU"},{color:1,kind:"FU"},{color:1,kind:"FU"}],
                [{},{},{},{},{},{},{},{},{}],
                [{},{},{},{},{},{},{},{},{}],
                [{},{},{},{},{},{},{},{},{}],
                [{},{},{},{},{},{},{},{},{}],
                [{},{},{},{},{},{},{},{},{}],
                [{},{},{},{},{},{},{},{},{}],
                [{},{},{},{},{},{},{},{},{}],
              ],
              color: 0,
              hands:[
                {"FU" => 0,"KY" => 4,"KE" => 0,"GI" => 0,"KI" => 0,"KA" => 0,"HI" => 2},
                {"FU" => 0,"KY" => 0,"KE" => 4,"GI" => 4,"KI" => 0,"KA" => 0,"HI" => 0},
              ]
            }
          },
          moves:[
            {},
            {move:{to:pos(1,3),piece:"KY"}},
            {move:{to:pos(1,2),piece:"KE"}},
            {move:{same:true,piece:"KY",promote:true}},
          ]
        ]
      }
    end
  end

  describe 'fork' do
    context 'normal' do
      let(:str) { "\
手合割：平手\n\
▲７六歩 △３四歩 ▲２二角成 △同　銀 ▲４五角\n\
まで5手で中断\n\
\n\
変化：3手\n\
▲６六歩 △８四歩"
      }

      it {
        is_expected.to eq Hash[
          header:{
            "手合割" => "平手",
          },
          initial: {preset: "HIRATE"},
          moves:[
            {},
            {move:{to:pos(7,6),piece:"FU"}},
            {move:{to:pos(3,4),piece:"FU"}},
            {move:{to:pos(2,2),piece:"KA",promote:true},forks:[
              [
                {move:{to:pos(6,6),piece:"FU"}},
                {move:{to:pos(8,4),piece:"FU"}},
              ]
            ]},
            {move:{same:true,piece:"GI"}},
            {move:{to:pos(4,5),piece:"KA"}},
            {special:"CHUDAN"},
          ]
        ]
      }
    end
  end
end
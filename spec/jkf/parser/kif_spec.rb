require 'spec_helper'

describe Jkf::Parser::Kif do
  let(:kif_parser) { Jkf::Parser::Kif.new }
  subject { kif_parser.parse(str) }

  shared_examples(:parse_file) do |filename|
    let(:str) do
      if File.extname(filename) == '.kif'
        File.read(filename, encoding: 'Shift_JIS').toutf8
      else
        File.read(filename).toutf8
      end
    end
    it "should be parse #{File.basename(filename)}" do
      is_expected.not_to be_nil
    end
  end

  fixtures(:kif).each do |fixture|
    it_behaves_like :parse_file, fixture
  end

  context 'simple' do
    let(:str) { "1 ７六歩(77)\n2 ３四歩(33)\n3 ２二角成(88)\n 4 同　銀(31)\n5 ４五角打\n" }
    it {
      is_expected.to eq Hash[
        "header" => {},
        "moves" => [
          {},
          {"move" =>{"from" =>pos(7,7),"to" =>pos(7,6),"piece" =>"FU","color"=>0}},
          {"move" =>{"from" =>pos(3,3),"to" =>pos(3,4),"piece" =>"FU","color"=>1}},
          {"move" =>{"from" =>pos(8,8),"to" =>pos(2,2),"piece" =>"KA","color"=>0,"promote" =>true}},
          {"move" =>{"from" =>pos(3,1),"same" =>true,"piece" =>"GI","color"=>1}},
          {"move" =>{"to" =>pos(4,5),"piece" =>"KA","color"=>0}},
        ]
      ]
    }
  end

  context 'gote' do
    let(:str) { <<-EOS
手合割：その他
上手番
上手の持駒：
  ９ ８ ７ ６ ５ ４ ３ ２ １
+---------------------------+
|v香v桂v銀v金v玉v金v銀v桂v香|一
| ・v飛 ・ ・ ・ ・ ・v角 ・|二
|v歩 ・v歩v歩v歩v歩v歩v歩v歩|三
| ・v歩 ・ ・ ・ ・ ・ ・ ・|四
| ・ ・ ・ ・ ・ ・ ・ ・ ・|五
| ・ ・ ・ ・ ・ ・ ・ ・ ・|六
| 歩 歩 歩 歩 歩 歩 歩 歩 歩|七
| ・ 角 ・ ・ ・ ・ ・ 飛 ・|八
| 香 桂 銀 金 玉 金 銀 桂 香|九
+---------------------------+
下手の持駒：
手数----指手---------消費時間--
   1 ３四歩(33)
   2 ７六歩(77)
   3 ８八角成(22)
   4 中断
まで3手で中断
EOS
    }

    it {
      is_expected.to eq Hash[
        "header" => { "手合割"=>"その他" },
        "initial" => {
          "preset"=>"OTHER",
          "data"=>{
            "board"=>[
              [{"color"=>1, "kind"=>"KY"}, {}, {"color"=>1, "kind"=>"FU"}, {}, {}, {}, {"color"=>0, "kind"=>"FU"}, {}, {"color"=>0, "kind"=>"KY"}],
              [{"color"=>1, "kind"=>"KE"}, {"color"=>1, "kind"=>"KA"}, {"color"=>1, "kind"=>"FU"}, {}, {}, {}, {"color"=>0, "kind"=>"FU"}, {"color"=>0, "kind"=>"HI"}, {"color"=>0, "kind"=>"KE"}],
              [{"color"=>1, "kind"=>"GI"}, {}, {"color"=>1, "kind"=>"FU"}, {}, {}, {}, {"color"=>0, "kind"=>"FU"}, {}, {"color"=>0, "kind"=>"GI"}],
              [{"color"=>1, "kind"=>"KI"}, {}, {"color"=>1, "kind"=>"FU"}, {}, {}, {}, {"color"=>0, "kind"=>"FU"}, {}, {"color"=>0, "kind"=>"KI"}],
              [{"color"=>1, "kind"=>"OU"}, {}, {"color"=>1, "kind"=>"FU"}, {}, {}, {}, {"color"=>0, "kind"=>"FU"}, {}, {"color"=>0, "kind"=>"OU"}],
              [{"color"=>1, "kind"=>"KI"}, {}, {"color"=>1, "kind"=>"FU"}, {}, {}, {}, {"color"=>0, "kind"=>"FU"}, {}, {"color"=>0, "kind"=>"KI"}],
              [{"color"=>1, "kind"=>"GI"}, {}, {"color"=>1, "kind"=>"FU"}, {}, {}, {}, {"color"=>0, "kind"=>"FU"}, {}, {"color"=>0, "kind"=>"GI"}],
              [{"color"=>1, "kind"=>"KE"}, {"color"=>1, "kind"=>"HI"}, {}, {"color"=>1, "kind"=>"FU"}, {}, {}, {"color"=>0, "kind"=>"FU"}, {"color"=>0, "kind"=>"KA"}, {"color"=>0, "kind"=>"KE"}],
              [{"color"=>1, "kind"=>"KY"}, {}, {"color"=>1, "kind"=>"FU"}, {}, {}, {}, {"color"=>0, "kind"=>"FU"}, {}, {"color"=>0, "kind"=>"KY"}]
            ],
            "color"=>1,
            "hands"=>[
              {"FU"=>0, "KY"=>0, "KE"=>0, "GI"=>0, "KI"=>0, "KA"=>0, "HI"=>0},
              {"FU"=>0, "KY"=>0, "KE"=>0, "GI"=>0, "KI"=>0, "KA"=>0, "HI"=>0}
            ]
          }
        },
        "moves" => [
          {},
          {"move" =>{"from" =>pos(3,3),"to" =>pos(3,4),"piece" =>"FU","color"=>1}},
          {"move" =>{"from" =>pos(7,7),"to" =>pos(7,6),"piece" =>"FU","color"=>0}},
          {"move" =>{"from" =>pos(2,2),"to" =>pos(8,8),"piece" =>"KA","color"=>1,"promote" =>true}},
          {"special" => "CHUDAN"}
        ]
      ]
    }
  end

  context 'comment' do
    let(:str) { "*開始時コメント\n1 ７六歩(77)\n*初手コメント\n*初手コメント2\n2 ３四歩(33)\n3 ２二角成(88)\n" }
    it {
      is_expected.to eq Hash[
        "header" =>{},
        "moves" =>[
          {"comments" =>["開始時コメント"]},
          {"move" =>{"from" =>pos(7,7),"to" =>pos(7,6),"piece" =>"FU","color"=>0},"comments" =>["初手コメント", "初手コメント2"]},
          {"move" =>{"from" =>pos(3,3),"to" =>pos(3,4),"piece" =>"FU","color"=>1}},
          {"move" =>{"from" =>pos(8,8),"to" =>pos(2,2),"piece" =>"KA","color"=>0,"promote" =>true}},
        ]
      ]
    }
  end

  context 'time' do
    let(:str) { "1 ７六歩(77) (0:01/00:00:01)\n2 ３四歩(33) (0:02/00:00:02)\n3 ２二角成(88) (0:20/00:00:21)\n 4 同　銀(31) (0:03/00:00:05)\n5 ４五角打 (0:39/00:01:00)\n" }
    it {
      is_expected.to eq Hash[
        "header" =>{},
        "moves" =>[
          {},
          {"move" =>{"from" =>pos(7,7),"to" =>pos(7,6),"piece" =>"FU","color"=>0},"time" =>{"now" =>{"m" =>0,"s" =>1},"total" =>{"h" =>0,"m" =>0,"s" =>1}}},
          {"move" =>{"from" =>pos(3,3),"to" =>pos(3,4),"piece" =>"FU","color"=>1},"time" =>{"now" =>{"m" =>0,"s" =>2},"total" =>{"h" =>0,"m" =>0,"s" =>2}}},
          {"move" =>{"from" =>pos(8,8),"to" =>pos(2,2),"piece" =>"KA","color"=>0,"promote" =>true},"time" =>{"now" =>{"m" =>0,"s" =>20},"total" =>{"h" =>0,"m" =>0,"s" =>21}}},
          {"move" =>{"from" =>pos(3,1),"same" =>true,"piece" =>"GI","color"=>1},"time" =>{"now" =>{"m" =>0,"s" =>3},"total" =>{"h" =>0,"m" =>0,"s" =>5}}},
          {"move" =>{"to" =>pos(4,5),"piece" =>"KA","color"=>0},"time" =>{"now" =>{"m" =>0,"s" =>39},"total" =>{"h" =>0,"m" =>1,"s" =>0}}},
        ]
      ]
    }
  end

  context 'total-time-ms' do
    let(:str) { "1 ７六歩(77) (0:01/00:01)\n2 ３四歩(33) (0:02/00:02)\n3 ２二角成(88) (0:20/00:21)\n 4 同　銀(31) (0:03/00:05)\n5 ４五角打 (0:39/01:00)\n" }
    it {
      is_expected.to eq Hash[
        "header" =>{},
        "moves" =>[
          {},
          {"move" =>{"from" =>pos(7,7),"to" =>pos(7,6),"piece" =>"FU","color"=>0},"time" =>{"now" =>{"m" =>0,"s" =>1},"total" =>{"h" =>0,"m" =>0,"s" =>1}}},
          {"move" =>{"from" =>pos(3,3),"to" =>pos(3,4),"piece" =>"FU","color"=>1},"time" =>{"now" =>{"m" =>0,"s" =>2},"total" =>{"h" =>0,"m" =>0,"s" =>2}}},
          {"move" =>{"from" =>pos(8,8),"to" =>pos(2,2),"piece" =>"KA","color"=>0,"promote" =>true},"time" =>{"now" =>{"m" =>0,"s" =>20},"total" =>{"h" =>0,"m" =>0,"s" =>21}}},
          {"move" =>{"from" =>pos(3,1),"same" =>true,"piece" =>"GI","color"=>1},"time" =>{"now" =>{"m" =>0,"s" =>3},"total" =>{"h" =>0,"m" =>0,"s" =>5}}},
          {"move" =>{"to" =>pos(4,5),"piece" =>"KA","color"=>0},"time" =>{"now" =>{"m" =>0,"s" =>39},"total" =>{"h" =>0,"m" =>1,"s" =>0}}},
        ]
      ]
    }
  end

  context 'special' do
    let(:str) { "1 ７六歩(77)\n2 ３四歩(33)\n3 ７八銀(79)\n 4 ８八角成(22)\n5 投了\nまで4手で後手の勝ち\n" }
    it {
      is_expected.to eq Hash[
        "header" =>{},
        "moves" =>[
          {},
          {"move" =>{"from" =>pos(7,7),"to" =>pos(7,6),"piece" =>"FU","color"=>0}},
          {"move" =>{"from" =>pos(3,3),"to" =>pos(3,4),"piece" =>"FU","color"=>1}},
          {"move" =>{"from" =>pos(7,9),"to" =>pos(7,8),"piece" =>"GI","color"=>0}},
          {"move" =>{"from" =>pos(2,2),"to" =>pos(8,8),"piece" =>"KA","color"=>1,"promote" =>true}},
          {"special" =>"TORYO"},
        ]
      ]
    }
  end

  describe 'header' do
    context '手合割 平手' do
      let(:str) { "手合割：平手\n1 ７六歩(77)\n2 ３四歩(33)\n3 ２二角成(88)\n 4 同　銀(31)\n5 ４五角打\n" }
      it {
        is_expected.to eq Hash[
          "header" =>{
            '手合割' => '平手',
          },
          "initial" => {"preset" => 'HIRATE'},
          "moves" =>[
            {},
            {"move" =>{"from" =>pos(7,7),"to" =>pos(7,6),"piece" =>'FU',"color"=>0}},
            {"move" =>{"from" =>pos(3,3),"to" =>pos(3,4),"piece" =>'FU',"color"=>1}},
            {"move" =>{"from" =>pos(8,8),"to" =>pos(2,2),"piece" =>'KA',"color"=>0,"promote" =>true}},
            {"move" =>{"from" =>pos(3,1),"same" =>true,"piece" =>'GI',"color"=>1}},
            {"move" =>{"to" =>pos(4,5),"piece" =>'KA',"color"=>0}},
          ]
        ]
      }
    end

    context '手合割 六枚落ち' do
      let(:str) { "手合割：六枚落ち\n1 ４二玉(51)\n2 ７六歩(77)\n3 ２二銀(31)\n 4 ６六角(88)\n5 ８二銀(71)\n" }

      it {
        is_expected.to eq Hash[
          "header" =>{
            '手合割' => '六枚落ち',
          },
          "initial" => {"preset" => '6'},
          "moves" =>[
            {},
            {"move" =>{"from" =>pos(5,1),"to" =>pos(4,2),"piece" =>'OU',"color"=>0}},
            {"move" =>{"from" =>pos(7,7),"to" =>pos(7,6),"piece" =>'FU',"color"=>1}},
            {"move" =>{"from" =>pos(3,1),"to" =>pos(2,2),"piece" =>'GI',"color"=>0}},
            {"move" =>{"from" =>pos(8,8),"to" =>pos(6,6),"piece" =>'KA',"color"=>1}},
            {"move" =>{"from" =>pos(7,1),"to" =>pos(8,2),"piece" =>'GI',"color"=>0}},
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
1 １三香打\n2 １二桂打\n3 同　香成(13)\n" }

      it {
        is_expected.to eq Hash[
          "header" =>{
            '手合割' => 'その他　',
            '上手' => 'uwate',
            '下手' => 'shitate',
          },
          "initial" => {
            "preset" =>'OTHER',
            "data" =>{
              "board" =>[
                [{"color" =>1,"kind" =>'OU'},{},{},{},{},{},{},{},{}],
                [{"color" =>1,"kind" =>'FU'},{"color" =>1,"kind" =>'FU'},{"color" =>1,"kind" =>'FU'},{"color" =>1,"kind" =>'FU'},{"color" =>1,"kind" =>'FU'},{"color" =>1,"kind" =>'FU'},{"color" =>1,"kind" =>'FU'},{"color" =>1,"kind" =>'FU'},{"color" =>1,"kind" =>'FU'}],
                [{},{},{},{},{},{},{},{},{}],
                [{},{},{},{},{},{},{},{},{}],
                [{},{},{},{},{},{},{},{},{}],
                [{},{},{},{},{},{},{},{},{}],
                [{},{},{},{},{},{},{},{},{}],
                [{},{},{},{},{},{},{},{},{}],
                [{},{},{},{},{},{},{},{},{}],
              ],
              "color" => 0,
              "hands" =>[
                {"FU"=>0,"KY"=>4,"KE"=>0,"GI"=>0,"KI"=>0,"KA"=>0,"HI"=>2},
                {"FU"=>0,"KY"=>0,"KE"=>4,"GI"=>4,"KI"=>0,"KA"=>0,"HI"=>0},
              ]
            }
          },
          "moves" =>[
            {},
            {"move" =>{"to" =>pos(1,3),"piece" =>'KY',"color"=>0}},
            {"move" =>{"to" =>pos(1,2),"piece" =>'KE',"color"=>1}},
            {"move" =>{"from" =>pos(1,3),"same" =>true,"piece" =>'KY',"color"=>0,"promote" =>true}},
          ]
        ]
      }
    end

    context 'Kifu for iPhone dialect' do
      let(:str) { "\
手合割：平手\n\
上手の持駒：銀四 桂四 \n\
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
下手の持駒：飛二 香四 \n\
下手番\n\
下手：shitate\n\
上手：uwate\n\
1 １三香打\n2 １二桂打\n3 同　香成(13)\n"
      }

      it {
        is_expected.to eq Hash[
          "header" =>{
            "手合割"=>"平手",
            "下手"=>"shitate",
            "上手"=>"uwate",
          },
          "initial" => {
            "preset" =>"OTHER",
            "data" =>{
              "board" =>[
                [{"color" =>1,"kind" =>"OU"},{},{},{},{},{},{},{},{}],
                [{"color" =>1,"kind" =>"FU"},{"color" =>1,"kind" =>"FU"},{"color" =>1,"kind" =>"FU"},{"color" =>1,"kind" =>"FU"},{"color" =>1,"kind" =>"FU"},{"color" =>1,"kind" =>"FU"},{"color" =>1,"kind" =>"FU"},{"color" =>1,"kind" =>"FU"},{"color" =>1,"kind" =>"FU"}],
                [{},{},{},{},{},{},{},{},{}],
                [{},{},{},{},{},{},{},{},{}],
                [{},{},{},{},{},{},{},{},{}],
                [{},{},{},{},{},{},{},{},{}],
                [{},{},{},{},{},{},{},{},{}],
                [{},{},{},{},{},{},{},{},{}],
                [{},{},{},{},{},{},{},{},{}],
              ],
              "color" => 0,
              "hands" =>[
                {"FU"=>0,"KY"=>4,"KE"=>0,"GI"=>0,"KI"=>0,"KA"=>0,"HI"=>2},
                {"FU"=>0,"KY"=>0,"KE"=>4,"GI"=>4,"KI"=>0,"KA"=>0,"HI"=>0},
              ]
            }
          },
          "moves" =>[
            {},
            {"move" =>{"to" =>pos(1,3),"piece" =>"KY","color"=>0}},
            {"move" =>{"to" =>pos(1,2),"piece" =>"KE","color"=>1}},
            {"move" =>{"from" =>pos(1,3),"same" =>true,"piece" =>"KY","color"=>0,"promote" =>true}},
          ]
        ]
      }
    end
  end

  describe "fork" do
    context "normal" do
      let(:str) { "\
手合割：平手\n\
1 ７六歩(77)\n\
2 ３四歩(33)\n\
3 ２二角成(88)+\n\
4 同　銀(31)\n\
5 ４五角打\n\
6 中断\n\
\n\
変化：3手\n\
3 ６六歩(67)\n\
4 ８四歩(83)\n\
"
      }

      it {
        is_expected.to eq Hash[
          "header" =>{
            "手合割" => "平手",
          },
          "initial" => {"preset" => "HIRATE"},
          "moves" =>[
            {},
            {"move" =>{"from" =>pos(7,7),"to" =>pos(7,6),"piece" =>"FU","color"=>0}},
            {"move" =>{"from" =>pos(3,3),"to" =>pos(3,4),"piece" =>"FU","color"=>1}},
            {"move" =>{"from" =>pos(8,8),"to" =>pos(2,2),"piece" =>"KA","color"=>0,"promote" =>true},"forks" =>[
              [
                {"move" =>{"from" =>pos(6,7),"to" =>pos(6,6),"piece" =>"FU","color"=>0}},
                {"move" =>{"from" =>pos(8,3),"to" =>pos(8,4),"piece" =>"FU","color"=>1}},
              ]
            ]},
            {"move" =>{"from" =>pos(3,1),"same" =>true,"piece" =>"GI","color"=>1}},
            {"move" =>{"to" =>pos(4,5),"piece" =>"KA","color"=>0}},
            {"special" =>"CHUDAN"},
          ]
        ]
      }
    end

    context 'gote' do
      let(:str) { <<-EOS
手合割：その他
上手番
上手の持駒：
  ９ ８ ７ ６ ５ ４ ３ ２ １
+---------------------------+
|v香v桂v銀v金v玉v金v銀v桂v香|一
| ・v飛 ・ ・ ・ ・ ・v角 ・|二
|v歩 ・v歩v歩v歩v歩v歩v歩v歩|三
| ・v歩 ・ ・ ・ ・ ・ ・ ・|四
| ・ ・ ・ ・ ・ ・ ・ ・ ・|五
| ・ ・ ・ ・ ・ ・ ・ ・ ・|六
| 歩 歩 歩 歩 歩 歩 歩 歩 歩|七
| ・ 角 ・ ・ ・ ・ ・ 飛 ・|八
| 香 桂 銀 金 玉 金 銀 桂 香|九
+---------------------------+
下手の持駒：
手数----指手---------消費時間--
   1 ３四歩(33)
   2 ７六歩(77)
   3 ８八角成(22)
   4 中断
まで3手で中断

変化：3手
3 ４四歩(43)
4 ２六歩(27)
EOS
      }

      it {
        is_expected.to eq Hash[
          "header" => { "手合割"=>"その他" },
          "initial" => {
            "preset"=>"OTHER",
            "data"=>{
              "board"=>[
                [{"color"=>1, "kind"=>"KY"}, {}, {"color"=>1, "kind"=>"FU"}, {}, {}, {}, {"color"=>0, "kind"=>"FU"}, {}, {"color"=>0, "kind"=>"KY"}],
                [{"color"=>1, "kind"=>"KE"}, {"color"=>1, "kind"=>"KA"}, {"color"=>1, "kind"=>"FU"}, {}, {}, {}, {"color"=>0, "kind"=>"FU"}, {"color"=>0, "kind"=>"HI"}, {"color"=>0, "kind"=>"KE"}],
                [{"color"=>1, "kind"=>"GI"}, {}, {"color"=>1, "kind"=>"FU"}, {}, {}, {}, {"color"=>0, "kind"=>"FU"}, {}, {"color"=>0, "kind"=>"GI"}],
                [{"color"=>1, "kind"=>"KI"}, {}, {"color"=>1, "kind"=>"FU"}, {}, {}, {}, {"color"=>0, "kind"=>"FU"}, {}, {"color"=>0, "kind"=>"KI"}],
                [{"color"=>1, "kind"=>"OU"}, {}, {"color"=>1, "kind"=>"FU"}, {}, {}, {}, {"color"=>0, "kind"=>"FU"}, {}, {"color"=>0, "kind"=>"OU"}],
                [{"color"=>1, "kind"=>"KI"}, {}, {"color"=>1, "kind"=>"FU"}, {}, {}, {}, {"color"=>0, "kind"=>"FU"}, {}, {"color"=>0, "kind"=>"KI"}],
                [{"color"=>1, "kind"=>"GI"}, {}, {"color"=>1, "kind"=>"FU"}, {}, {}, {}, {"color"=>0, "kind"=>"FU"}, {}, {"color"=>0, "kind"=>"GI"}],
                [{"color"=>1, "kind"=>"KE"}, {"color"=>1, "kind"=>"HI"}, {}, {"color"=>1, "kind"=>"FU"}, {}, {}, {"color"=>0, "kind"=>"FU"}, {"color"=>0, "kind"=>"KA"}, {"color"=>0, "kind"=>"KE"}],
                [{"color"=>1, "kind"=>"KY"}, {}, {"color"=>1, "kind"=>"FU"}, {}, {}, {}, {"color"=>0, "kind"=>"FU"}, {}, {"color"=>0, "kind"=>"KY"}]
              ],
              "color"=>1,
              "hands"=>[
                {"FU"=>0, "KY"=>0, "KE"=>0, "GI"=>0, "KI"=>0, "KA"=>0, "HI"=>0},
                {"FU"=>0, "KY"=>0, "KE"=>0, "GI"=>0, "KI"=>0, "KA"=>0, "HI"=>0}
              ]
            }
          },
          "moves" => [
            {},
            {"move" =>{"from" =>pos(3,3),"to" =>pos(3,4),"piece" =>"FU","color"=>1}},
            {"move" =>{"from" =>pos(7,7),"to" =>pos(7,6),"piece" =>"FU","color"=>0}},
            {
              "move" =>{"from" =>pos(2,2),"to" =>pos(8,8),"piece" =>"KA","color"=>1,"promote" =>true},
              "forks"=>[[
                {"move"=>{"from"=>pos(4,3),"to"=>pos(4,4),"piece"=>"FU","color"=>1}},
                {"move"=>{"from"=>pos(2,7),"to"=>pos(2,6),"piece"=>"FU","color"=>0}}
              ]]
            },
            {"special" => "CHUDAN"}
          ]
        ]
      }
    end
  end

  describe "split" do
    context "normal" do
      let(:str) { "\
手合割：平手\n\
手数----指手--\n\
*開始コメント\n\
1 ７六歩(77)\n\
*初手コメント\n\
2 ３四歩(33)\n\
3 ２二角成(88)+\n\
4 中断\n\
"
      }

      it {
        is_expected.to eq Hash[
          "header" =>{
            "手合割" => "平手",
          },
          "initial" => {"preset" => "HIRATE"},
          "moves" =>[
            {"comments" =>["開始コメント"]},
            {"move" =>{"from" =>pos(7,7),"to" =>pos(7,6),"piece" =>"FU","color"=>0},"comments" =>["初手コメント"]},
            {"move" =>{"from" =>pos(3,3),"to" =>pos(3,4),"piece" =>"FU","color"=>1}},
            {"move" =>{"from" =>pos(8,8),"to" =>pos(2,2),"piece" =>"KA","color"=>0,"promote" =>true}},
            {"special" =>"CHUDAN"},
          ]
        ]
      }
    end

    context "after initial comment" do
      let(:str) { "\
手合割：平手\n\
*開始コメント\n\
手数----指手--\n\
1 ７六歩(77)\n\
*初手コメント\n\
2 ３四歩(33)\n\
3 ２二角成(88)+\n\
4 中断\n\
"
      }

      it {
        is_expected.to eq Hash[
          "header" =>{
            "手合割" => "平手",
          },
          "initial" => {"preset" => "HIRATE"},
          "moves" =>[
            {"comments" =>["開始コメント"]},
            {"move" =>{"from" =>pos(7,7),"to" =>pos(7,6),"piece" =>"FU","color"=>0},"comments" =>["初手コメント"]},
            {"move" =>{"from" =>pos(3,3),"to" =>pos(3,4),"piece" =>"FU","color"=>1}},
            {"move" =>{"from" =>pos(8,8),"to" =>pos(2,2),"piece" =>"KA","color"=>0,"promote" =>true}},
            {"special" =>"CHUDAN"},
          ]
        ]}
    end
  end

  describe "unsupported annotations" do
    context "盤面回転" do
      let(:str) { "盤面回転\n1 ７六歩(77)\n2 ３四歩(33)\n3 ２二角成(88)\n 4 同　銀(31)\n5 ４五角打\n" }

      it {
        is_expected.to eq Hash[
          "header" =>{},
          "moves" =>[
            {},
            {"move" =>{"from" =>pos(7,7),"to" =>pos(7,6),"piece" =>"FU","color"=>0}},
            {"move" =>{"from" =>pos(3,3),"to" =>pos(3,4),"piece" =>"FU","color"=>1}},
            {"move" =>{"from" =>pos(8,8),"to" =>pos(2,2),"piece" =>"KA","color"=>0,"promote" =>true}},
            {"move" =>{"from" =>pos(3,1),"same" =>true,"piece" =>"GI","color"=>1}},
            {"move" =>{"to" =>pos(4,5),"piece" =>"KA","color"=>0}},
          ]
        ]
      }
    end

    context "&読み込み時表示" do
      let(:str) { "1 ７六歩(77)\n2 ３四歩(33)\n&読み込み時表示\n3 ２二角成(88)\n 4 同　銀(31)\n5 ４五角打\n" }

      it {
        is_expected.to eq Hash[
          "header" =>{},
          "moves" =>[
            {},
            {"move" =>{"from" =>pos(7,7),"to" =>pos(7,6),"piece" =>"FU","color"=>0}},
            {"move" =>{"from" =>pos(3,3),"to" =>pos(3,4),"piece" =>"FU","color"=>1},"comments" =>["&読み込み時表示"]},
            {"move" =>{"from" =>pos(8,8),"to" =>pos(2,2),"piece" =>"KA","color"=>0,"promote" =>true}},
            {"move" =>{"from" =>pos(3,1),"same" =>true,"piece" =>"GI","color"=>1}},
            {"move" =>{"to" =>pos(4,5),"piece" =>"KA","color"=>0}},
          ]
        ]
      }
    end
  end
end

package popups
{
    import assets.GameBackgroundColor;
    import classes.Box;
    import classes.BoxButton;
    import classes.Language;
    import classes.Text;
    import com.flashfla.components.Throbber;
    import com.flashfla.utils.NumberUtil;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.BlurFilter;
    import flash.geom.Point;
    import menu.MenuPanel;
    import com.flashfla.loader.DataEvent;
    import com.flashfla.utils.ObjectUtil;

    public class PopupHighscores extends MenuPanel
    {
        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _lang:Language = Language.instance;

        //- Background
        private var box:Box;
        private var bmd:BitmapData;
        private var bmp:Bitmap;

        private var page:int = 0;
        private var maxPage:int = 2147483647; // Max Int Limit
        private var throbber:Throbber;
        private var pageText:Text;
        private var myUsernameText:Text;
        private var myScoreText:Text;
        private var myAVText:Text;
        private var songDetails:Object;
        private var scorePane:Sprite;

        private var prevBtn:BoxButton;
        private var nextBtn:BoxButton;
        private var closeBtn:BoxButton;
        private var refreshBtn:BoxButton;

        public function PopupHighscores(myParent:MenuPanel, songDetails:Object)
        {
            super(myParent);
            this.songDetails = songDetails;
        }

        override public function stageAdd():void
        {
            bmd = new BitmapData(Main.GAME_WIDTH, Main.GAME_HEIGHT, false, 0x000000);
            bmd.draw(stage);
            bmd.applyFilter(bmd, bmd.rect, new Point(), new BlurFilter(16, 16, 3));
            bmp = new Bitmap(bmd);

            this.addChild(bmp);

            var bgbox:Box = new Box(Main.GAME_WIDTH - 40, Main.GAME_HEIGHT - 40, false, false);
            bgbox.x = 20;
            bgbox.y = 20;
            bgbox.color = GameBackgroundColor.BG_POPUP;
            bgbox.normalAlpha = 0.5;
            bgbox.activeAlpha = 1;
            this.addChild(bgbox);

            box = new Box(Main.GAME_WIDTH - 40, Main.GAME_HEIGHT - 40, false, false);
            box.x = 20;
            box.y = 20;
            box.activeAlpha = 0.4;
            this.addChild(box);

            var titleDisplay:Text = new Text(songDetails.name, 20);
            titleDisplay.x = 5;
            titleDisplay.y = 8;
            titleDisplay.width = box.width - 10;
            titleDisplay.align = Text.CENTER;
            box.addChild(titleDisplay);

            pageText = new Text("Page " + (page + 1));
            pageText.x = 200;
            pageText.y = box.height - 42;
            box.addChild(pageText);

            var infoRanks:Object = _gvars.activeUser.getLevelRank(songDetails);
            // Username
            myUsernameText = new Text("#" + infoRanks.rank + ": " + _gvars.activeUser.name, 16, "#D9FF9E");
            myUsernameText.x = 25;
            myUsernameText.y = 345;
            myUsernameText.width = 164;
            box.addChild(myUsernameText);

            // Score
            myScoreText = new Text(NumberUtil.numberFormat(infoRanks.rawscore), 15, "#B8D8B3");
            myScoreText.x = 360;
            myScoreText.y = 345;
            myScoreText.width = 150;
            box.addChild(myScoreText);

            // AV
            myAVText = new Text(infoRanks.results, 15, "#99B793");
            myAVText.x = 545;
            myAVText.y = 345;
            myAVText.width = 200;
            box.addChild(myAVText);

            //- Previous
            prevBtn = new BoxButton(79.5, 27, "PREVIOUS");
            prevBtn.x = 10;
            prevBtn.y = box.height - 42;
            prevBtn.addEventListener(MouseEvent.CLICK, clickHandler);
            box.addChild(prevBtn);

            //- Next
            nextBtn = new BoxButton(79.5, 27, "NEXT");
            nextBtn.x = 100;
            nextBtn.y = box.height - 42;
            nextBtn.addEventListener(MouseEvent.CLICK, clickHandler);
            box.addChild(nextBtn);

            //- Close
            closeBtn = new BoxButton(79.5, 27, "CLOSE");
            closeBtn.x = box.width - 94.5;
            closeBtn.y = box.height - 42;
            closeBtn.addEventListener(MouseEvent.CLICK, clickHandler);
            box.addChild(closeBtn);

            //- Refresh
            refreshBtn = new BoxButton(79.5, 27, "REFRESH");
            refreshBtn.x = box.width - 184.5;
            refreshBtn.y = box.height - 42;
            refreshBtn.addEventListener(MouseEvent.CLICK, clickHandler);
            box.addChild(refreshBtn);

            //- Render List
            renderHighscores();
        }

        private function renderHighscores():void
        {
            if (scorePane)
            {
                box.removeChild(scorePane);
                scorePane = null;
            }
            scorePane = new Sprite();
            scorePane.y = 50;
            box.addChild(scorePane);

            var textLine:Text;
            var urank:Text;
            var tY:int = 0;

            if (throbber)
            {
                if (box.contains(throbber))
                    box.removeChild(throbber);
                throbber.stop();
            }

            if (page > maxPage)
                page = maxPage;

            var highscores:Object = _gvars.getHighscores(songDetails.level);
            if (highscores && (highscores[(10 * page) + 1] != null))
            {
                // Username
                textLine = new Text("Username:", 16, "#C6F0FF");
                textLine.x = 25;
                textLine.y = tY;
                textLine.width = 200;
                scorePane.addChild(textLine);

                // Score
                textLine = new Text("Score:", 15, "#C6F0FF");
                textLine.x = 360;
                textLine.y = tY;
                textLine.width = 150;
                scorePane.addChild(textLine);

                // AV
                textLine = new Text("PA Spread:", 15, "#C6F0FF");
                textLine.x = 545;
                textLine.y = tY;
                textLine.width = 200;
                scorePane.addChild(textLine);
                tY += 30;

                var lastRank:int = 0;
                var lastScore:Number = Number.MAX_VALUE;
                for (var vr:int = 1; vr <= 10; vr++)
                {
                    var r:int = (10 * page) + vr;
                    if (highscores[r])
                    {
                        var username:String = highscores[r]['name'];
                        var score:Number = highscores[r]['score'];
                        var av:String = highscores[r]['av'];
                        var isMyPB:Boolean = (!_gvars.activeUser.isGuest) && (_gvars.activeUser.name == username);

                        // Username
                        textLine = new Text("#" + r + ": " + username, 16);
                        textLine.x = 25;
                        textLine.y = tY;
                        textLine.width = 200;
                        textLine.fontColor = isMyPB ? "#D9FF9E" : "#FFFFFF";
                        scorePane.addChild(textLine);

                        // Score
                        textLine = new Text(NumberUtil.numberFormat(score), 15);
                        textLine.x = 360;
                        textLine.y = tY;
                        textLine.width = 150;
                        textLine.fontColor = isMyPB ? "#B8D8B3" : "#DDDDDD";
                        scorePane.addChild(textLine);

                        // AV
                        textLine = new Text(av, 15);
                        textLine.x = 545;
                        textLine.y = tY;
                        textLine.width = 200;
                        textLine.fontColor = isMyPB ? "#99B793" : "#BBBBBB";
                        scorePane.addChild(textLine);
                        tY += 25;
                    }
                    else
                    {
                        maxPage = page;
                        break;
                    }
                }
            }
            else
            {
                if (!throbber)
                {
                    throbber = new Throbber();
                    throbber.x = box.width / 2 - 16;
                    throbber.y = box.height / 2 - 16;
                }
                box.addChild(throbber);
                throbber.start();

                _gvars.addEventListener(GlobalVariables.HIGHSCORES_LOAD_COMPLETE, highscoresLoaded);
                _gvars.loadHighscores(songDetails.level, page * 10);
            }
            pageText.text = "Page " + (page + 1);

            prevBtn.enabled = page == 0 ? false : true;
            prevBtn.alpha = page == 0 ? 0.5 : 1;
            nextBtn.enabled = page == maxPage ? false : true;
            nextBtn.alpha = page == maxPage ? 0.5 : 1;
        }

        private function highscoresLoaded(e:DataEvent):void
        {
            _gvars.removeEventListener(GlobalVariables.HIGHSCORES_LOAD_COMPLETE, highscoresLoaded);
            if (e.data.error == null)
            {
                var newEntriesCount:uint = ObjectUtil.count(e.data);
                // No entries but no error, last page.
                if (newEntriesCount == 0)
                {
                    page--;
                    maxPage = page;
                }
                // Less then 10 entries, most likely the last page.
                else if (newEntriesCount < 10)
                {
                    maxPage = page;
                }
            }
            renderHighscores();
        }

        private function refreshPersonalRanks():void
        {
            var infoRanks:Object = _gvars.activeUser.getLevelRank(songDetails);
            myUsernameText.text = "#" + infoRanks.rank + ": " + _gvars.activeUser.name;
            myScoreText.text = NumberUtil.numberFormat(infoRanks.rawscore);
            myAVText.text = infoRanks.results;
        }

        override public function stageRemove():void
        {
            box.dispose();
            this.removeChild(box);
            this.removeChild(bmp);
            bmd = null;
            bmp = null;
            box = null;
        }

        private function clickHandler(e:MouseEvent):void
        {
            if (e.target == prevBtn)
            {
                if (page > 0)
                {
                    page--;
                    renderHighscores();
                }
            }
            if (e.target == nextBtn)
            {
                page++;
                renderHighscores();
            }
            if (e.target == refreshBtn)
            {
                _gvars.clearHighscores();
                _gvars.activeUser.loadLevelRanks();
                refreshPersonalRanks();
                renderHighscores();
            }

            //- Close
            if (e.target == closeBtn)
            {
                removePopup();
                return;
            }
        }
    }

}

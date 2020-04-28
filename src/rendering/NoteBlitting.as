package rendering
{
    import classes.Noteskins;
    import classes.chart.Note;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.geom.Rectangle;
    import flash.geom.Point;
    import classes.GameNote;
    import flash.display.Sprite;
    import flash.geom.Matrix;

    public class NoteBlitting
    {
        // Global References
        private static var _noteskins:Noteskins = Noteskins.instance;

        // Local Statics
        private static var noteskinsCache:Vector.<BitmapData>;
        public static const rotationTable:Vector.<Number> = new <Number>[0.5, 1, 0, 1.5];

        public static const directionTable:Array = ["L", "U", "D", "R"];
        public static const noteColorsTable:Array = ["red", "blue", "purple", "yellow", "pink", "orange", "cyan", "green", "white"];

        private static var notePoint:Point = new Point(0, 0);

        public static function RenderNotes(canvasRectangle:Rectangle, drawTarget:BitmapData, notesToDraw:Vector.<GameNote>):void
        {
            // THE FOLLOWING IS EXAMPLE CODE:
            // NOTE: Draw from the top->down.

            drawTarget.fillRect(canvasRectangle, 0x00000000);

            // Create a shape to read from a bitmap.
            var noteRect:Rectangle = new Rectangle(0, 0, 64, 64);
            var noteMatrix:Matrix = new Matrix();

            for each (var note:GameNote in notesToDraw)
            {
                // Use a static to avoid new() (Apply offset).
                notePoint.x += note.x;
                notePoint.y += note.y;

                // Get the source bitmap to draw.
                var index:int = note.GetIndex();
                var noteBitmap:BitmapData = noteskinsCache[note.GetIndex()]

                noteRect.width = noteBitmap.width;
                noteRect.height = noteBitmap.height;

                noteMatrix.identity();
                noteMatrix.translate(-(noteRect.left + (noteRect.width / 2)), -(noteRect.top + (noteRect.height / 2)));

                if (note.rotation != 0)
                {
                    noteMatrix.rotate(note.rotation);
                }

                if (note.scaleX != 1.0 || note.scaleY != 1.0)
                {
                    noteMatrix.scale(note.scaleX, note.scaleY);
                }

                noteMatrix.translate(noteRect.left + (noteRect.width / 2), noteRect.top + (noteRect.height / 2));

                var noteClone:BitmapData = new BitmapData(noteBitmap.width, noteBitmap.height, true, 0x00000000);
                noteClone.draw(noteBitmap, noteMatrix);

                // Copy the pixels to the appropriate position on the screen.
                drawTarget.copyPixels(noteClone, noteRect, notePoint, null, null, true);

                // Use a static to avoid new() (Undo offset).
                notePoint.x -= note.x;
                notePoint.y -= note.y;
            }
        }

        public static function CacheNoteskin(noteskinIndex:int):void
        {
            var noteskinsData:Object = _noteskins.data[noteskinIndex];
            if (noteskinsData != null)
            {
                var notes:Object = noteskinsData["notes"];
                noteskinsCache = new Vector.<BitmapData>();
                for (var directionIndex:int = 0; directionIndex < directionTable.length; directionIndex++)
                {
                    for (var colorIndex:int = 0; colorIndex < noteColorsTable.length; colorIndex++)
                    {
                        var notesColor:Object = notes[noteColorsTable[colorIndex]];
                        if (notesColor == null)
                        {
                            notesColor = notes["blue"];
                        }

                        var noteSkinObject:* = notesColor[directionTable[directionIndex]]
                        if (noteSkinObject != null && noteSkinObject is BitmapData)
                        {
                            noteskinsCache.push(noteSkinObject);
                        }
                        else
                        {
                            var noteskinBitmap:BitmapData = null;
                            if (noteSkinObject == null)
                            {
                                var noteskinSprite0:Sprite = new notesColor["D"];
                                var rect:Rectangle = new Rectangle(0, 0, noteskinSprite0.width, noteskinSprite0.height);
                                var matrix:Matrix = new Matrix();
                                matrix.translate(-(rect.left + (rect.width / 2)), -(rect.top + (rect.height / 2)));
                                matrix.rotate(rotationTable[directionIndex] * Math.PI);
                                matrix.translate(rect.left + (rect.width / 2), rect.top + (rect.height / 2));
                                noteskinBitmap = new BitmapData(noteskinSprite0.width, noteskinSprite0.height, true, 0x00000000)
                                noteskinBitmap.draw(noteskinSprite0, matrix);
                                noteskinsCache.push(noteskinBitmap);
                            }
                            else
                            {
                                var noteskinSprite:Sprite = new noteSkinObject;
                                noteskinBitmap = new BitmapData(noteskinSprite.width, noteskinSprite.height, true, 0x00000000)
                                noteskinBitmap.draw(noteskinSprite);
                                noteskinsCache.push(noteskinBitmap);
                            }

                            if (notePoint == null)
                            {
                                var width:Number = noteskinBitmap.width;
                                var height:Number = noteskinBitmap.height;
                                notePoint = new Point(-(width >> 1), -(height >> 1));
                            }
                        }
                    }

                    // Buffer to fill index to 9.
                    noteskinsCache.push(new BitmapData(1, 1));
                }
            }
        }
    }
}

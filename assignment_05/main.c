#include <gst/gst.h>
#include <glib.h>


static gboolean
bus_call (GstBus     *bus,
          GstMessage *msg,
          gpointer    data)
{
  GMainLoop *loop = (GMainLoop *) data;

  switch (GST_MESSAGE_TYPE (msg)) {

    case GST_MESSAGE_EOS:
      g_print ("End of stream\n");
      g_main_loop_quit (loop);
      break;

    case GST_MESSAGE_ERROR: {
      gchar  *debug;
      GError *error;

      gst_message_parse_error (msg, &error, &debug);
      g_free (debug);

      g_printerr ("Error: %s\n", error->message);
      g_error_free (error);

      g_main_loop_quit (loop);
      break;
    }
    default:
      break;
  }

  return TRUE;
}


int
main (int   argc,
      char *argv[])
{
  GMainLoop *loop;

  GstElement *pipeline, *source, *encoder, *capsfilter, *decoder, *sink;
  GstBus *bus;
  guint bus_watch_id;

  /* Initialisation */
  gst_init (&argc, &argv);

  loop = g_main_loop_new (NULL, FALSE);


  /* Check input arguments */
  if (argc != 3) {
    g_printerr ("Usage: %s <Device name> <Output file>\n", argv[0]);
    return -1;
  }

  /* Create gstreamer elements */
  pipeline   = gst_pipeline_new ("video-storer");
  source     = gst_element_factory_make ("v4l2src",       "webcam-source");
  encoder    = gst_element_factory_make ("jpegenc",       "jpeg-encoder");
  capsfilter = gst_element_factory_make ("capsfilter",    "capsfilter");
  decoder    = gst_element_factory_make ("jpegdec",       "jpeg-decoder");
  sink       = gst_element_factory_make ("filesink",      "file-output");

  if (!pipeline || !source || !encoder || !capsfilter || !decoder || !sink) {
    g_printerr ("One element could not be created. Exiting.\n");
    return -1;
  }

  /* Set up the pipeline */

  /* we set the input and output filename to the source element */
  g_object_set (G_OBJECT (source), "device", argv[1], NULL);
  g_object_set (G_OBJECT (sink), "location", argv[2], NULL);
  g_object_set (G_OBJECT (capsfilter), "caps", "image/jpeg,width=640,height=480,framerate=30/1", NULL);


  /* we add a message handler */
  bus = gst_pipeline_get_bus (GST_PIPELINE (pipeline));
  bus_watch_id = gst_bus_add_watch (bus, bus_call, loop);
  gst_object_unref (bus);

  /* we add all elements into the pipeline */
  /* file-source | ogg-demuxer | vorbis-decoder | converter | alsa-output */
  gst_bin_add_many (GST_BIN (pipeline),
                    source, encoder, capsfilter, decoder, sink, NULL);

  /* we link the elements together */
  /* file-source -> ogg-demuxer ~> vorbis-decoder -> converter -> alsa-output */
  gst_element_link_many (source, encoder, capsfilter, decoder, sink, NULL);


  /* Set the pipeline to "playing" state*/
  g_print ("Now recording:\n");
  gst_element_set_state (pipeline, GST_STATE_PLAYING);


  /* Iterate */
  g_print ("Running...\n");
  g_main_loop_run (loop);


  /* Out of the main loop, clean up nicely */
  g_print ("Returned, stopped recording\n");
  gst_element_set_state (pipeline, GST_STATE_NULL);

  g_print ("Deleting pipeline\n");
  gst_object_unref (GST_OBJECT (pipeline));
  g_source_remove (bus_watch_id);
  g_main_loop_unref (loop);

  return 0;
}
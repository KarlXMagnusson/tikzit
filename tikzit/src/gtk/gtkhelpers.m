//
//  gtkhelpers.h
//  TikZiT
//  
//  Copyright 2010 Alex Merry. All rights reserved.
//
//  Some code from Glade:
//    Copyright 2001 Ximian, Inc.
//  
//  This file is part of TikZiT.
//  
//  TikZiT is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  TikZiT is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with TikZiT.  If not, see <http://www.gnu.org/licenses/>.
//  
#import "gtkhelpers.h"
#import <gdk/gdkkeysyms.h>

NSString * gtk_editable_get_string (GtkEditable *editable, gint start, gint end)
{
    gchar *text = gtk_editable_get_chars (editable, start, end);
    NSString *string = [NSString stringWithUTF8String:text];
    g_free (text);
    return string;
}

GdkRectangle gdk_rectangle_from_ns_rect (NSRect box) {
    GdkRectangle rect;
    rect.x = box.origin.x;
    rect.y = box.origin.y;
    rect.width = box.size.width;
    rect.height = box.size.height;
    return rect;
}

NSRect gdk_rectangle_to_ns_rect (GdkRectangle rect) {
    NSRect result;
    result.origin.x = rect.x;
    result.origin.y = rect.y;
    result.size.width = rect.width;
    result.size.height = rect.height;
    return result;
}

void gtk_action_set_detailed_label (GtkAction *action, const gchar *baseLabel, const gchar *actionName) {
  if (actionName == NULL || *actionName == '\0') {
    gtk_action_set_label (action, baseLabel);
  } else {
    GString *label = g_string_sized_new (30);
    g_string_printf(label, "%s: %s", baseLabel, actionName);
    gtk_action_set_label (action, label->str);
    g_string_free (label, TRUE);
  }
}

/**
 * tz_hijack_key_press:
 * @win: a #GtkWindow
 * event: the GdkEventKey
 * user_data: unused
 *
 * This function is meant to be attached to key-press-event of a toplevel,
 * it simply allows the window contents to treat key events /before/
 * accelerator keys come into play (this way widgets dont get deleted
 * when cutting text in an entry etc.).
 *
 * Returns: whether the event was handled
 */
gint
tz_hijack_key_press (GtkWindow    *win,
                     GdkEventKey  *event,
                     gpointer      user_data)
{
    GtkWidget *focus_widget;

    focus_widget = gtk_window_get_focus (win);
    if (focus_widget &&
        (event->keyval == GDK_Delete || /* Filter Delete from accelerator keys */
         ((event->state & GDK_CONTROL_MASK) && /* CTRL keys... */
          ((event->keyval == GDK_c || event->keyval == GDK_C) || /* CTRL-C (copy)  */
           (event->keyval == GDK_x || event->keyval == GDK_X) || /* CTRL-X (cut)   */
           (event->keyval == GDK_v || event->keyval == GDK_V) || /* CTRL-V (paste) */
           (event->keyval == GDK_a || event->keyval == GDK_A) || /* CTRL-A (select-all) */
           (event->keyval == GDK_n || event->keyval == GDK_N))))) /* CTRL-N (new document) ?? */
    {
            return gtk_widget_event (focus_widget,
                                     (GdkEvent *)event);
    }
    return FALSE;
}

GdkPixbuf * pixbuf_get_from_surface(cairo_surface_t *surface) {
    cairo_surface_flush (surface);

    int width = cairo_image_surface_get_width (surface);
    int height = cairo_image_surface_get_height (surface);
    int stride = cairo_image_surface_get_stride (surface);
    unsigned char *data = cairo_image_surface_get_data (surface);

    GdkPixbuf *pixbuf = gdk_pixbuf_new (GDK_COLORSPACE_RGB,
                                        TRUE,
                                        8,
                                        width,
                                        height);
    unsigned char *pbdata = gdk_pixbuf_get_pixels (pixbuf);
    int pbstride = gdk_pixbuf_get_rowstride (pixbuf);

    for (int y = 0; y < height; ++y) {
        uint32_t *line = (uint32_t*)(data + y*stride);
        unsigned char *pbline = pbdata + (y*pbstride);
        for (int x = 0; x < width; ++x) {
            uint32_t pixel = *(line + x);
            unsigned char *pbpixel = pbline + (x*4);
            // NB: We should un-pre-mult the alpha here.
            //     However, in our world, alpha is always
            //     on or off, so it doesn't really matter
            pbpixel[3] = ((pixel & 0xff000000) >> 24);
            pbpixel[0] = ((pixel & 0x00ff0000) >> 16);
            pbpixel[1] = ((pixel & 0x0000ff00) >> 8);
            pbpixel[2] =  (pixel & 0x000000ff);
        }
    }

    return pixbuf;
}

// vim:ft=objc:ts=8:et:sts=4:sw=4

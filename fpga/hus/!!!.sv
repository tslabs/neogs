
  // always_latch
    // if (!hus_en)
    // begin
      // hus_state_next = HST_0;
      // ch_radr_next = 1'b0;
      // st_radr_next = 1'b0;
    // end

    // else
    // begin
      // case (hus_state)
        // HST_0:
        // begin

          // channel is inactive
          // if (ch_nact_f)
          // begin
            // hus_state_next = ch_last_f ? HST_LAST : HST_0;

            // ch_rreg_next = 3'd7;
            // st_rreg_next = 3'd5;
          // end

          // channel retriggered
          // else if (ch_rtg_f)
          // begin
            // hus_state_next = HST_1;
            // ch_rreg_next = 3'd1;
          // end

          // channel continues playing
          // else
          // begin
            // use old sample
            // if (!st_rrq_f)
            // begin
              // hus_state_next = HST_5;
              // ch_rreg_next = 3'd5;
              // st_rreg_next = 3'd3;
            // end

            // read new sample from RAM
            // else
            // begin
              // hus_state_next = HST_;
              // ch_rreg_next = 3'd2;
              // st_rreg_next = 3'd5;
            // end
          // end

          // st_we_next = 1'b0;
          // mf_req = 1'b0;
        // end

        // HST_1:
        // begin
          // hus_state_next = mf_busy ? HST_1 : HST_2;
          // mf_req = !mf_busy;
          // ch_rreg_next = 3'd5;
          // st_we_next = 1'b0;
        // end

        // HST_2:
        // begin
          // hus_state_next = HST_3;
          // ch_rreg_next = 3'd6;
          // st_wreg_next = 3'd0;
          // st_wdat_next[15:4] = sub_addr_new[11:0];
          // st_wdat_next[2] = 1'b1;
          // st_wdat_next[1] = 1'b0;
          // st_wdat_next[0] = 1'b1;
          // st_we_next = 1'b1;
        // end

        // HST_3:  // ready to kick sample interpolator, sample to be read from RAM
        // begin
          // hus_state_next = HST_4;
          // st_wreg_next = 3'd1;
          // st_wdat_next = new_addr[15:0];
          // st_we_next = 1'b1;
        // end

        HST_4:
        begin
          hus_state_next = ch_last_f ? HST_LAST : HST_0;
          ch_rreg_next = 3'd7;
          st_rreg_next = 3'd5;
          st_wreg_next = 3'd2;
          st_wdat_next[5:0] = new_addr[21:16];
          st_we_next = 1'b1;
        end

        HST_5:
        begin
          ch_rreg_next = 3'd6;
          st_rreg_next = 3'd4;

          // address not changed
          if (~|addr_inc)
          begin
            hus_state_next = HST_6;
            st_wreg_next = 3'd0;
            st_wdat_next[15:4] = sub_addr_new[11:0];
            st_wdat_next[2] = 1'b0;
            st_wdat_next[1] = st_dir;
            st_wdat_next[0] = 1'b1;
            st_we_next = 1'b1;
          end

          // address is incremented
          else
          begin
            // move forward
            if (!st_dir)
              hus_state_next = HST_7;

            // move backward
            else
              // hus_state_next = HST_7;

            st_we_next = 1'b0;
          end
        end

        HST_6:  // ready to kick sample interpolator, sample ready
        begin
          hus_state_next = ch_last_f ? HST_LAST : HST_0;
          st_we_next = 1'b0;
        end

        HST_7:  // ready to kick sample interpolator, sample ready
        begin
          hus_state_next = HST_8;
          ch_rreg_next = 3'd2;
          st_rreg_next = 3'd1;
          st_we_next = 1'b0;
        end

        HST_8:
        begin
          hus_state_next = HST_9;
          ch_rreg_next = 3'd3;
          st_rreg_next = 3'd2;
          st_we_next = 1'b0;
        end

        HST_9:
        begin
        end

        default:
        begin
          hus_state_next = hus_state;
          st_we_next = 1'b0;
        end
      endcase

      ch_radr_next = ch_addr + ch_rreg_next;
      st_radr_next = st_addr + st_rreg_next;
    end


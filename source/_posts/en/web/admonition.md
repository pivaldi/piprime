- mettre le css
- Utiliser un {% gist gist_id [filename] %}

```sass
////
/// Copyright (c) 2016-2018 Martin Donath <martin.donath@squidfunk.com>
//  Modified by Philippe Ivaldi <contact@piprime.fr> to handle angular material design.
///
/// Permission is hereby granted, free of charge, to any person obtaining a
/// copy of this software and associated documentation files (the "Software"),
/// to deal in the Software without restriction, including without limitation
/// the rights to use, copy, modify, merge, publish, distribute, sublicense,
/// and/or sell copies of the Software, and to permit persons to whom the
/// Software is furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL
/// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
/// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
/// DEALINGS
////

// ----------------------------------------------------------------------------
// Rules
// ----------------------------------------------------------------------------

// Base code come from https://github.com/squidfunk/mkdocs-material/blob/master/src/assets/stylesheets/extensions/_admonition.scss
@import "~theme_variables.scss";

$ms-base: 1.6rem;
$md-icon-size:                        $ms-base * 1.5;
$md-icon-padding:                     $ms-base * 0.5;
$md-icon-margin:                      $ms-base * 0.25;

// Icon placeholders
%md-icon {
  font-family: "Material Icons";
  font-style: normal;
  font-variant: normal;
  font-weight: normal;
  line-height: 1;
  text-transform: none;
  white-space: nowrap;
  speak: none;
  word-wrap: normal;
  direction: ltr;
}

$clr-blue-a200: mat-color(mat-palette($mat-blue, 200));
$clr-light-blue-a400: mat-color(mat-palette($mat-light-blue, 400));
$clr-cyan-a700: mat-color(mat-palette($mat-cyan, 700));
$clr-teal-a700: mat-color(mat-palette($mat-teal, 700));
$clr-green-a700: mat-color(mat-palette($mat-green, 700));
$clr-light-green-a700: mat-color(mat-palette($mat-light-green, 700));
$clr-orange-a400: mat-color(mat-palette($mat-orange, 400));
$clr-red-a200: mat-color(mat-palette($mat-red, 200));
$clr-red-a400: mat-color(mat-palette($mat-red, 400));
$clr-pink-a400: mat-color(mat-palette($mat-pink, 400));
$clr-deep-purple-a400: mat-color(mat-palette($mat-deep-purple, 400));
$clr-grey: mat-color(mat-palette($mat-grey));

.admonition {
  @include mat-elevation(2);

  position: relative;
  margin: 1.5625em 0;
  padding: 0 1.2rem;
  border-left: 0.4rem solid $clr-blue-a200;
  border-radius: 0.2rem;
  font-size: mat-font-size($mat-typography-config, body-1);
  overflow: auto;

  // Adjust for RTL languages
  [dir="rtl"] & {
    border-right: 0.4rem solid $clr-blue-a200;
    border-left: none;
  }

  // Adjust spacing on last element
  html & > :last-child {
    margin-bottom: 1.2rem;
  }

  // Adjust margin for nested admonition blocks
  .admonition {
    margin: 1em 0;
  }

  // Title
  > .admonition-title {
    margin: 0 -1.2rem;
    padding: 0.8rem 1.2rem 0.8rem 4rem;
    border-bottom: 0.1rem solid transparentize($clr-blue-a200, 0.9);
    background-color: transparentize($clr-blue-a200, 0.9);
    font-weight: 700;

    // Adjust for RTL languages
    [dir="rtl"] & {
      padding: 0.8rem 4rem 0.8rem 1.2rem;
    }

    // Reset spacing, if title is the only element
    &:last-child {
      margin-bottom: 0;
    }

    // Icon
    &::before {
      @extend %md-icon;

      position: absolute;
      left: 1.2rem;
      color: $clr-blue-a200;
      font-size: 1.6rem;
      content: "\E3C9"; // edit

      // Adjust for RTL languages
      [dir="rtl"] & {
        right: 1.2rem;
        left: initial;
      }
    }
  }

  // Build representational classes
  @each $names, $appearance in (
    abstract summary tldr: $clr-light-blue-a400 "\E8D2", // subject
    info todo: $clr-cyan-a700 "\E88E", // info
    tip hint important : $clr-teal-a700 "\E80E", // whatshot
    success check done: $clr-green-a700 "\E876", // done
    question help faq: $clr-light-green-a700 "\E887", // help
    warning caution attention: $clr-orange-a400 "\E002", // warning
    failure fail missing: $clr-red-a200 "\E14C", // clear
    danger error: $clr-red-a400 "\E3E7", // flash_on
    bug: $clr-pink-a400 "\E868", // bug_report
    example: $clr-deep-purple-a400 "\E242", // format_list_numbered
    quote cite: $clr-grey "\E244" // format_quote
  ) {
    $tint: nth($appearance, 1);
    $icon: nth($appearance, 2);

    // Define base class
    &%#{nth($names, 1)},
    &.#{nth($names, 1)} {
      border-left-color: $tint;

      // Adjust for RTL languages
      [dir="rtl"] & {
        border-right-color: $tint;
      }

      // Title
      > .admonition-title {
        border-bottom: 0.1rem solid transparentize($tint, 0.9);
        background-color: transparentize($tint, 0.9);

        // Icon
        &::before {
          color: $tint;
          content: $icon;
        }
      }
    }

    // Define synonyms for base class
    @if length($names) > 1 {
      @for $n from 2 through length($names) {
        &.#{nth($names, $n)} {
          @extend .admonition%#{nth($names, 1)};
        }
      }
    }
  }
}
```
